"""Tool to merge configs from different formats."""
import argparse
import os
import re
from configparser import ConfigParser
from pathlib import Path

import toml


def merge(source: dict, destination: dict) -> dict:
    """Deep merge dictionaries."""
    for key, value in source.items():
        if isinstance(value, dict):
            node = destination.setdefault(key, {})
            merge(value, node)
        else:
            destination[key] = value

    return destination


def change_header(config: dict, from_header: str, to_header: str) -> dict:
    """Change header in a config."""
    sub_config = config
    if from_header:
        sub_keys = from_header.split(".")
        for sub_key in sub_keys:
            if _sub_config := sub_config.get(sub_key):
                sub_config = _sub_config
            else:
                return {}

    return {to_header: sub_config}


def parse_toml(config_file: str) -> dict:
    """Utility function to parse a toml file."""
    with open(config_file, encoding="utf-8") as cfg:
        return toml.load(cfg)


def parse_ini(config_file: str) -> dict:
    """Utility function to parse a ini file."""
    config = ConfigParser()
    config.read(config_file, encoding="utf-8")
    return config._sections  # pylint: disable=protected-access


def parse_lists_for_toml(config_file) -> None:
    """Parse list from ill defined config formats."""
    for key, value in config_file.items():
        if isinstance(value, str):
            arr = (
                re.sub(r"\s*|\r?\n|#.*$", "", value, flags=re.MULTILINE)
                .rstrip(",")
                .split(",")
            )

            if len(arr) > 1:
                config_file[key] = arr

        elif isinstance(value, dict):
            parse_lists_for_toml(value)


def mypy_overrides(config_file, key) -> dict:
    """Special function to handle mypy module override headers."""
    overrides = config_file
    keys = key.split(".")
    for override_key in keys:
        overrides = overrides.get(override_key)
        if overrides is None:
            return {}

    root = {}
    for override in overrides:
        module_name = f'mypy-{override.pop("module")}'
        root.update(
            {
                module_name: override,
            }
        )
    to_remove = config_file
    for remove_key in keys[:-1]:
        to_remove = to_remove.get(remove_key)

    to_remove.pop(keys[-1])
    return root


def clean_up_fields(read_config, config_file, key, remove_fields):
    """Remove fields from a config."""
    if key in remove_fields and config_file in remove_fields[key]:
        for remove in remove_fields[key][config_file]:
            root = read_config
            split = remove.split(".")
            to_remove = split[-1]
            for root_key in split[:-1]:
                root = root.get(root_key)
                if root is None:
                    break
            else:
                if to_remove in root:
                    root.pop(to_remove)

    return read_config


def parse_remove_fields(remove_fields_raw):
    """Parse a list of remove fields to a dict."""
    remove_fields = {}
    for field in remove_fields_raw:
        split = field.split("=", 1)
        key_file = split[0]
        remove_values = split[1].split(",")
        split = key_file.split(":")
        key = split[0]
        config_file = split[1]

        remove_fields.setdefault(
            key,
            {
                config_file: [],
            },
        )
        values = remove_fields.get(key).get(config_file)
        values.extend(remove_values)

    return remove_fields


def main():
    """Construct a config from a set of configs."""
    parser = argparse.ArgumentParser(
        prog="config-merger", description="Merges config files"
    )
    parser.add_argument("-t", "--tool", help="The tool the config files are for")
    parser.add_argument(
        "--remove-fields",
        metavar="KEY=VALUES",
        nargs="*",
        help="Fields to be removed",
        default=[],
    )
    parser.add_argument(
        "-o",
        "--out-file",
        help="Place to write the combined config to.",
        type=Path,
    )
    parser.add_argument("-f", "--files", nargs="+", default=[])
    args = parser.parse_args()
    tool_name = args.tool
    remove_fields = parse_remove_fields(args.remove_fields)

    combined_config = {}
    out_file = args.out_file

    for config_file, key in filter(
        lambda cfg: cfg[0].exists(),
        map(
            lambda item: (Path(item.split("=")[0]), item.split("=")[1]),
            args.files,
        ),
    ):
        if os.environ.get("CONFIG_MERGER_DEBUG"):
            print(f"Using {args.tool} settings from {config_file.absolute()}")

        match config_file.suffix:
            case ".toml":
                read_config = parse_toml(config_file)
            case _:
                read_config = parse_ini(config_file)
                if out_file.suffix == ".toml" and tool_name == "pylint":
                    parse_lists_for_toml(read_config)

        read_config = clean_up_fields(
            read_config, os.path.basename(config_file), key, remove_fields
        )
        overrides = {}
        if (
            out_file.suffix != ".toml"
            and tool_name == "mypy"
            and key == "tool.mypy.overrides"
        ):
            overrides = mypy_overrides(read_config, key)

        read_config = change_header(read_config, key, tool_name)
        read_config.update(overrides)
        combined_config = merge(combined_config, read_config)

    with open(out_file, "w", encoding="utf-8") as output_file:
        if out_file.suffix == ".toml":
            toml.dump({"tool": combined_config}, output_file)
        else:
            config_parser = ConfigParser()
            config_parser.read_dict(combined_config)
            config_parser.write(output_file)


if __name__ == "__main__":
    main()
