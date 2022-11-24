{ base }:
let
  # Get a nightly version
  # Note that the oxalica attribute was added in overrides.nix.
  rustRelease = base.languages.rust.oxalica.nightly."2022-11-29".default.override {
    extensions = [ "rust-analyzer" "rust-src" ];
  };
in
# Apply the nightly version before calling mkClient
(base.languages.rust.override (base.languages.rust.mkRustToolset {
  rustc = rustRelease;
  cargo = rustRelease;
  clippy = rustRelease;
  rust-analyzer = rustRelease;
  rustfmt = rustRelease;
})).mkClient {
  name = "rust-nightly";
  version = "0.1.0";
  src = ./.;
}
