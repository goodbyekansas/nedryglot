{ base, pkgsCross, lib }:
(base.languages.rust.overrideCrossTargets (_previousCrossTargets: {
  # Adding a custom cross target for `RISC-V`.
  riscFive = base.languages.rust.mkCrossTarget {
    name = "RISC-V";
    pkgs = pkgsCross.riscv64;
    attrs = _: {
      shellCommands = {
        run = {
          script = ''echo "Can not run riscv applications."'';
          show = false;
        };
      };
    };
  };
})).mkClient {
  name = "rusty-rust-cross";
  src = ./.;
  executableName = "rusty-rust";
  buildInputs = pkgs: lib.optional pkgs.stdenv.hostPlatform.isRiscV64 pkgs.hello;
}
