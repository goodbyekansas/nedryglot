{
  description = "Example project demonstrating how to override language configurations.";

  inputs = {
    pkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    nedryglot.url = "path:../..";
    nedryglot.inputs.nixpkgs.follows = "pkgs";
    nedryland.follows = "nedryglot/nedryland";
    oxalica.url = "github:oxalica/rust-overlay";
  };

  outputs = { pkgs, nedryglot, nedryland, oxalica, ... }:
    let
      # TODO: not necessarily
      system = "x86_64-linux";

      pkgs' = pkgs.legacyPackages."${system}";
      project = import ./project.nix {
        nedryglot = nedryglot.lib."${system}" { };
        nedryland = nedryland.lib."${system}";
        oxalica = oxalica.overlays.default;
        pkgs = pkgs';
      };
    in
    {
      packages."${system}" = project.matrix // {
        default = project.components;
      };
      devShells."${system}" = project.shells;
    };
}
