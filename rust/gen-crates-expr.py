from pathlib import Path
import argparse
import io
import json
import sys
import tarfile
import tempfile
import typing
import urllib.request

from semver import VersionInfo as Version

FETCH_CRATE_EXPR = '''  {name} = fetchCrate {{
    name = "{name}";
    version = "{version}";
    sha256 = "{sha256}";
    deps = [ {deps} ];
  }};'''


class DownloadLocation:
    def __init__(self, filepath: typing.Optional[Path] = None):
        self.tempfile = None
        self.args = []
        if filepath:
            self.filepath = filepath
        else:
            self.tempfile = tempfile.NamedTemporaryFile("w+b")
            self.filepath = Path(self.tempfile.name)

    @property
    def need_download(self):
        if self.tempfile:
            return True
        return not self.filepath.exists()

    # The os.PathLike interface
    def __fspath__(self):
        return str(self.filepath)


def to_nix_expression(content: io.BufferedReader, version: typing.Optional[str], include_optional_deps: bool, rust_version: typing.Optional[Version]) -> (str, typing.List[str]):
    """Generate a nix expression from a file inside a tar archive.

    Args:
        content: A file inside a tar archive.
        version: Use a specific version instead of latest.
        include_optional_deps: If optional dependencies should be returned in the deps list

    Returns:
        (str, list): The nix expression to fetch the crate and a list of dependencies.
    """
    versions = map(json.loads, content.readlines())
    for version_info in sorted(versions, key=lambda v: Version.parse(v.get("vers")), reverse=True):
        if version is not None and version_info["vers"] != version:
            continue
        # Only take prerelease if specifically asked for, otherwise cargo will stop you.
        if not version and Version.parse(version_info["vers"]).prerelease:
            continue
        if rust_version and Version(*version_info.get("rust_version", "0.0.0").split(".")) > rust_version:
            continue
        if not version_info["yanked"]:
            deps = set(
                map(
                    lambda dep: (dep.get("package", dep["name"]), dep.get("optional", False)),
                    filter(
                        lambda dep: True if dep.get("optional", False) and include_optional_deps else not dep.get("optional", False),
                        filter(
                            lambda dep: dep.get("kind") in ["normal", "build"] and dep.get("name") != version_info["name"],
                            version_info["deps"]
                        )
                    )
                )
            )
            return (
                FETCH_CRATE_EXPR.format(
                    name=version_info["name"],
                    version=version_info["vers"],
                    sha256=version_info["cksum"],
                    deps=" ".join(sorted([dep[0] for dep in deps if not dep[1]])),
                ),
                list([dep[0] for dep in deps]),
            )
    return ("", [])

def is_crate(tar_member: tarfile.TarInfo) -> bool:
    """Filter tar member to only include files describing crates.

    Exclude everything in the .github folder, everything with an extension and
    directories.

    Args:
        tar_member: The object representing a file in the tar archive.

    Returns:
        bool: whether a file is a crate description.
    """
    return (
        tar_member.isreg()
        and tar_member.name.split("/")[1] != ".github"
        and "." not in tar_member.name.split("/")[-1]
    )

def main(github_ref: str, crates: typing.List[str], output: typing.Optional[Path], include_deps: bool, optional_deps: bool, silent: bool, index_location: typing.Optional[Path], rust_version: typing.Optional[Version]) -> None:
    """Generate a nix expression to fetch crates from crates.io index.

    Args:
        github_ref: The ref to use on creates.io-index.
        creates: The list of crate names to look up.
        output: An optional file to output to instead of stdout.
        include_deps: If nix expressions should be generated for dependencies.
        optional_deps: If optional dependencies should be considered.
        silent: If progress and messages should be omitted.
        index_location: Path to where the index is or will be stored.
        rust_version: The optional rust version to restrict with.
    """

    visited_crates = []
    crates_to_visit = crates
    result = {}

    index_location = DownloadLocation(index_location)

    if index_location.need_download:
        if not silent:
            print(f"Downloading crates index at {github_ref}...", file=sys.stderr)
        with urllib.request.urlopen(f"https://github.com/rust-lang/crates.io-index/tarball/{github_ref}") as tarball:
            with open(index_location, "w+b") as index_file:
                index_file.write(tarball.read())

    if not silent:
        print("Opening crate index tarball...", file=sys.stderr)
    with tarfile.open(index_location) as tar:
        for crate in crates_to_visit:
            if not silent:
                print(f"Looking for {crate}...", file=sys.stderr)
            visited_crates.append(crate)
            for tar_member in filter(is_crate, tar.getmembers()):
                if tar_member.name.split("/")[-1] == crate.split(":")[0]:
                    version = crate.split(":")[1] if ":" in crate else None
                    expr, deps = to_nix_expression(tar.extractfile(tar_member.name), version, optional_deps, rust_version)
                    if expr:
                        result[crate.split(":")[0]] = expr
                    if include_deps and deps:
                        crates_to_visit.extend([c for c in deps if c not in visited_crates and c not in crates_to_visit])
                    break

    result = map(lambda x: x[1], sorted(result.items()))
    expression = "fetchCrate: rec{\n" + "\n\n".join(result) + "\n}"

    if output:
        with open(output, "w") as out:
            out.write(expression)
    else:
        print(expression)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate a nix expression to fetch rust crates when building with Nedryglot's rust language tooling.")
    parser.add_argument("--ref", type=str, help="Git ref of https://github.com/rust-lang/crates.io-index to use for crate lookup, if omitted master is used.", default="master")
    parser.add_argument("--output", type=Path, help="Write output to a file instead of stdout.")
    parser.add_argument("--no-deps", action="store_true", help="Turn off dependency traversal and only download the listed crates.")
    parser.add_argument("--optional-deps", action="store_true", help="Include optional dependencies.")
    parser.add_argument("--silent", action="store_true", help="Do not print progress and info to stderr.")
    parser.add_argument("crates", nargs="*", help="A space separated list of crates to generate expressions for. Use name:version to fetch a specific version.", default=[])
    parser.add_argument("--index-path", help="Location to load the index from, downloads to this location if nothing is there", type=Path)
    parser.add_argument("--rust-version", help="Restrict crates that supports this version", type=lambda v: Version.parse(v))
    args = parser.parse_args()
    main(args.ref, args.crates, args.output, not args.no_deps, args.optional_deps, args.silent, args.index_path, args.rust_version)
    sys.exit(0)

