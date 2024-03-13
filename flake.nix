{
  description = "Polyglot extension for Nedryland.";

  inputs = {
    nedryland = {
      url = "github:goodbyekansas/nedryland/10.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "nixpkgs/nixos-23.11";
    nixpkgs_22_11.url = "nixpkgs/nixos-22.11";
  };

  outputs = { nedryland, flake-utils, nixpkgs, nixpkgs_22_11, ... }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config = {
              allowUnfreePredicate = pkg:
                builtins.elem
                  (builtins.parseDrvName pkg.name or pkg.pname).name
                  [ "terraform" ];
            };
          };
          nedry = nedryland.lib."${system}" {
            inherit pkgs;
          };
        in
        {
          lib = import ./.;
          packages = {
            inherit (nedry) checks;
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
            gen-default-crates = {
              type = "app";
              program = "${pkgs.writeScriptBin
                "gen-default-crates"
                ''
                  PYTHONPATH="${pkgs.python3.pkgs.semver}/${pkgs.python3.sitePackages}" \
                  ${pkgs.python3}/bin/python ${./rust/gen-crates-expr.py} \
                  $(${pkgs.curl}/bin/curl -s "https://crates.io/api/v1/crates?per_page=100&sort=downloads" | ${pkgs.jq}/bin/jq -r '[.crates[].name]|join(" ")') prost prost-derive \
                  "$@"
                ''
                }/bin/gen-default-crates";
            };
          };
        }
      );
}
