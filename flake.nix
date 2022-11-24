{
  description = "Polyglot extension for Nedryland.";

  inputs.nedryland.url = github:goodbyekansas/nedryland/move-to-nedryglot;
  inputs.flake-utils.url = github:numtide/flake-utils;
  inputs.oxalica.url = github:oxalica/rust-overlay;
  inputs.nixpkgs.url = "nixpkgs/nixos-22.05";

  outputs = { nedryland, flake-utils, oxalica, nixpkgs, ... }:
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
        }
      ) // (
      let
        system = "x86_64-linux"; # TODO eachDefaultSystem does not work correctly for
        pkgs = nixpkgs.legacyPackages."${system}";
        nedryland' = nedryland.lib."${system}";
      in
      {
        checks."${system}".default = builtins.derivation {
          inherit system;
          name = "all-tests";
          builder = "${pkgs.bash}/bin/bash";
          args = [ "-c" ''${pkgs.coreutils}/bin/touch $out'' ];
          tests = builtins.filter (x: x != { })
            (import ./test.nix {
              inherit oxalica pkgs;
              nedryland = nedryland';
              usingFlakes = true;
            }).all;
        };
      }
    );
}

