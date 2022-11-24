oxalica:
{ base, pkgs }:
let
  rust = oxalica (pkgs // rust) pkgs;

  # Pick a rust release
  rustRelease = rust.rust-bin.stable."1.65.0".default.override {
    extensions = [ "rust-analyzer" "rust-src" ];

    # If the project has any cross compile targets you need to list
    # the corresponding rustup distributions for them here. This is
    # specific to the oxalica overlay since it uses rustup. In
    # nixpkgs this works out of the box.
    # targets = [];
  };
in
{
  # Apply the rust release for all tools
  languages.rust = (base.languages.rust.override (base.languages.rust.mkRustToolset {
    rustc = rustRelease;
    cargo = rustRelease;
    clippy = rustRelease;
    rust-analyzer = rustRelease;
    rustfmt = rustRelease;
  })) // { oxalica = rust.rust-bin; };

  # Override the python targets you want for your components.
  languages.python = base.languages.python.override {
    # Set the default python version.
    python = pkgs.python38;
    pythonVersions = {
      inherit (pkgs) python38 python39 python310;
    };
  };
}
