#! /usr/bin/env bash

declare -a CRATEPATH=()
setup_cratepath() {
    shopt -s globstar
    shopt -s nullglob

    for cratepath in "$1"/**/Cargo.toml; do
        CRATEPATH+=("$(dirname "$cratepath")")
    done
}

setup_cargo_home() {
    mkdir -p "$NIX_BUILD_TOP"/.nedryglot
    echo "[source.crates-io]
directory=\"$NIX_BUILD_TOP/.nedryglot/dependency-crates\"

[registries]
nix = { index = \"https://fake-nix-registry/not-really-an-index\" }

[source.nix]
registry = \"https://fake-nix-registry/not-really-an-index\"
replace-with = \"crates-io\"
    " >"$NIX_BUILD_TOP"/.nedryglot/config.toml
    export CARGO_HOME="$NIX_BUILD_TOP"/.nedryglot

    if [ -n "${NEDRYGLOT_DEBUG_CRATES:-}" ]; then
        echo "Set CARGO_HOME to $CARGO_HOME"
    fi
}

link_crates() {
    if [ "${#CRATEPATH[@]}" -eq 0 ]; then
        return
    fi
    setup_cargo_home
    crates="$NIX_BUILD_TOP"/.nedryglot/dependency-crates
    mkdir -p "$crates"
    for crate in "${CRATEPATH[@]}"; do
        name="$crates/$(echo "$crate" | sed -E 's|/nix/store/\w{32}-||')"

        if [ -n "${NEDRYGLOT_DEBUG_CRATES:-}" ]; then
            echo "linking crate \"$name\" at \"$crate\"..."
        fi

        if [ ! -e "$crates/$(basename "$name")" ]; then
            ln -s "$crate" "$crates/$(basename "$name")"
        fi
    done
}

remove_external_crate_references() {
    # The binary we built will be full of paths pointing to the nix store.
    # Nix thinks it is doing us a favour by automatically adding dependencies
    # by finding store paths in the binary. We strip these store paths so
    # Nix won't find them.
    for crate in "$NIX_BUILD_TOP"/.nedryglot/dependency-crates/*; do
        find "${out:-}" -type f -exec remove-references-to -t "$(realpath "$crate")" '{}' +
    done
}

remove_rustlibsrc() {
    # rustLibSrc is not required for rustPlatform
    find "${out:-}" -type f -exec remove-references-to -t "@rustLibSrc@" '{}' +
}

remove_source_dependencies() {
    if [ -e Cargo.toml ]; then
        sed -i '/\[patch\.nix\]/,/^[.*]$/d' Cargo.toml
    fi
}


addEnvHooks "${targetOffset:-0}" setup_cratepath
preConfigureHooks+=(link_crates)
preFixupHooks+=(remove_external_crate_references)
@addPrefixupHook@
setup_cargo_home
shellHook="${shellHook:-}
link_crates
"

if [ -z "${IN_NIX_SHELL:-}" ]; then
  export RUSTFLAGS="${RUSTFLAGS:-} --remap-path-prefix $NIX_BUILD_TOP=build-root"
  preConfigureHooks+=(remove_source_dependencies)
fi
