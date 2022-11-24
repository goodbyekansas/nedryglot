# Overriding the Rust Version

`base.languages.rust` exposes the function `overrideRust` to change the
build/lint tools. This function takes a number of required arguments to override
the specific tools. The non-overriden tools are the following:

```nix
nedryland.mkProject
{
  baseExtensions = [
    # Nedryglot itself needs to be imported first to have something to override.
    nedryglot 
    # Then we define our override.
    ({ base }: {
      languages.rust = base.languages.rust.override (base.languages.rust.mkRustToolset {
        rustc = nixpkgs.rustPlatform.rustc;
        cargo = nixpkgs.rustPlaform.cargo;
        clippy = nixpkgs.clippy;
        rust-analyzer = nixpkgs.rust-analyzer;
        rustfmt = nixpkgs.rustfmt;
      });
    })
  ];
}
```

Individual components can of course override the rust version. This can be useful when needing new features from nightly, without forcing the entire Nedryland project to use nightly. This example shows
how to make a service with a different rust version, assuming the variable `nightly` has been created with attributes:

```nix
{ base }:
(base.languages.rust.override (base.languages.rust.mkRustToolset {
  rustc = nightly.rustc;
  cargo = nightly.cargo;
  clippy = nightly.clippy;
  rust-analyzer = nightly.rust-analyzer;
  rustfmt = nightly.rustfmt;
})).mkService {
  name = "example-service";
  src = ./.;
}
```

See the override example for how to use the [oxalica](https://github.com/oxalica/rust-overlay) overlay.
