c:
let
  service = c.mkService { name = "c-name"; version = "1.0.1"; src = null; };
in
# Ensure default target
assert service ? _default;

pkgs:
let
  cCross = c.override {
    platforms = {
      windows = c.mkPlatform {
        name = "🪟";
        pkgs = pkgs.pkgsCross.mingwW64;
      };
      wasi = c.mkPlatform
        {
          name = "🐑";
          pkgs = pkgs.pkgsCross.wasi32;
        };
    };
  };

  library = (cCross.override {
    platforms = {
      _default = cCross.platforms.windows;
    };
  }).mkLibrary {
    name = "Bibblan";
    version = "2.3.7";
    src = null;
  };

  libraryWasi = cCross.mkLibrary {
    name = "Bókasafn";
    version = "7.7.7";
    src = null;
  };

  libraryRiscv = (cCross.override {
    platforms = {
      _default = cCross.mkPlatform {
        name = "risk-🕔";
        pkgs = pkgs.pkgsCross.riscv32;

        platformOverrides = pkgAttrs: {
          # Note that we only put required dependencies here for the platform.
          buildInputs = pkgAttrs.buildInputs or [ ] ++
            [ pkgs.pkgsCross.riscv32.pkgs.systrayhelper ];
        };
      };
    };
  }).mkLibrary {
    name = "Kirjasto";
    version = "0.4.1b";
    src = null;
  };
in
# With new default target we should have only _default
assert library ? _default && !(library ? windows);
# Default target should be there unless overridden
assert libraryWasi ? _default && libraryWasi ? wasi && libraryWasi._default != libraryWasi.wasi;
# With inline, default cross target
assert libraryRiscv ? _default;

builtins.trace ''✔️ C tests succeeded ${c.emoji}''
{ }
