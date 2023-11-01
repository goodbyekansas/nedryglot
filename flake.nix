{
  description = "Polyglot extension for Nedryland.";

  inputs.nedryland = {
    url = github:goodbyekansas/nedryland/9.0.0;
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.flake-utils.url = github:numtide/flake-utils;
  inputs.nixpkgs.url = "nixpkgs/nixos-22.05";
  inputs.nixpkgs_22_11.url = "nixpkgs/nixos-22.11";

  outputs = { nedryland, flake-utils, nixpkgs, nixpkgs_22_11, ... }:
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
            tests_22_11 =
              let
                nedry_22_11 = nedryland.lib."${system}" {
                  pkgs = nixpkgs_22_11.legacyPackages."${system}";
                };
              in
              builtins.filter
                (x: x != { })
                (import ./test.nix nedry_22_11).all;

            tests = builtins.filter
              (x: x != { })
              (import ./test.nix nedry).all;
          };

          apps = nedryland.apps.${system} // {
            gen-crate-expression = {
              type = "app";
              program = "${pkgs.writeScriptBin
                "gen-crates-expr"
                ''
                  PYTHONPATH="${pkgs.python3.pkgs.semver}/${pkgs.python3.sitePackages}" \
                  ${pkgs.python3}/bin/python ${./rust/gen-crates-expr.py} "$@"
                ''
                }/bin/gen-crates-expr";
            };
          };
        }
      );
}

