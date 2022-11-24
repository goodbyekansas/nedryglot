{
  description = "Example project demonstrating simple components using Nedryglot languages.";

  inputs = {
    pkgs.url = github:NixOS/nixpkgs/nixos-22.11;
    nedryland.url = github:goodbyekansas/nedryland/move-to-nedryglot;
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
