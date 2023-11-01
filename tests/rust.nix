rust:
let
  service = rust.mkService { name = "rust-name"; version = "1.0.0"; src = null; };
in
# Check that the component contains docs with api
assert service ? docs && service.docs ? api;
# Ensure rust target
assert service ? rust;

pkgs:
let

  rustCross = rust.override {
    crossTargets = {
      windows = rust.mkCrossTarget {
        name = "🪟";
        pkgs = pkgs.pkgsCross.mingwW64;
      };
      wasi = rust.mkCrossTarget
        {
          name = "🐑";
          pkgs = pkgs.pkgsCross.wasi32;
        };
    };
  };

  library = (rustCross.override {
    crossTargets = {
      rust = rustCross.crossTargets.windows;
    };
  }).mkLibrary {
    name = "El biblioteqa";
    version = "2.3.4";
    src = null;
  };

  libraryWasi = rustCross.mkLibrary {
    name = "Bókasafn";
    version = "7.7.7";
    src = null;
  };

  libraryRiscv = (rustCross.override {
    crossTargets = {
      rust = rustCross.mkCrossTarget {
        name = "risk-🕔";
        pkgs = pkgs.pkgsCross.riscv32;

        attrs = pkgAttrs: {
          # Note that we only put required dependencies here for the platform.
          buildInputs = rustCross.combineInputs
            (pkgAttrs.buildInputs or [ ])
            (pkgs: [ pkgs.systrayhelper ]);
        };
      };
    };
  }).mkLibrary {
    name = "Kirjasto";
    version = "0.0.1b";
    src = null;
  };
in
# With new default target we should have only rust
assert library ? rust && !(library ? windows);
# Default target should be there unless overridden
assert libraryWasi ? rust && libraryWasi ? wasi && libraryWasi.rust != libraryWasi.wasi;
# With inline, default cross target
assert libraryRiscv ? rust;

{ }
