{
  description = "Example project demonstrating Protobuf functionality.";

  inputs = {
    pkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    nedryglot.url = "path:../..";
    nedryglot.inputs.nixpkgs.follows = "pkgs";
    nedryland.follows = "nedryglot/nedryland";
  };

  outputs = { pkgs, nedryland, ... }:
    let
      # TODO: not necessarily
      system = "x86_64-linux";

      pkgs' = pkgs.legacyPackages."${system}";
      project = import ./project.nix {
        nedryland = nedryland.lib."${system}";
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
