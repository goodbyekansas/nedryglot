{
  description = "Example project demonstrating simple components using Nedryglot languages.";

  inputs = {
    pkgs.url = github:NixOS/nixpkgs/nixos-22.11;
    nedryglot.url = path:../../;
    nedryland.follows = "nedryglot/nedryland";
  };

  outputs = { pkgs, nedryland, nedryglot, ... }:
    let
      # TODO: not necessarily
      system = "x86_64-linux";

      pkgs' = pkgs.legacyPackages."${system}";
      project = import ./project.nix {
        nedryland = nedryland.lib."${system}";
        nedryglot = nedryglot.lib."${system}";
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
