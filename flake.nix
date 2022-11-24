{
  description = "Polyglot extension for Nedryland.";

  inputs.nedryland.url = github:goodbyekansas/nedryland/move-to-nedryglot;
  inputs.flake-utils.url = github:numtide/flake-utils;
  inputs.nixpkgs.url = "nixpkgs/nixos-22.05";

  outputs = { nedryland, flake-utils, nixpkgs, ... }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = nixpkgs.legacyPackages."${system}";
          nedry = nedryland.lib."${system}" {
            inherit pkgs;
          };
        in
        {
          lib = import ./.;
          packages = {
            checks = nedry.checks;
            docs = import ./docs.nix {
              inherit pkgs;
            };
          };

          checks.default = builtins.derivation {
            inherit system;
            name = "all-tests";
            builder = "${pkgs.bash}/bin/bash";
            args = [ "-c" ''${pkgs.coreutils}/bin/touch $out'' ];
            tests = builtins.filter
              (x: x != { })
              (import ./test.nix nedry).all;
          };

          apps = nedryland.apps.${system};
        }
      );
}

