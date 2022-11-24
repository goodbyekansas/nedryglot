{
  description = "Example project demonstrating how to override language configurations.";

  inputs = {
    pkgs.url = github:NixOS/nixpkgs/nixos-22.11;
    nedryland.url = github:goodbyekansas/nedryland/move-to-nedryglot;
    oxalica.url = github:oxalica/rust-overlay;
  };

  outputs = { pkgs, nedryland, oxalica, ... }:
    let
      # TODO: not necessarily
      system = "x86_64-linux";

      pkgs' = pkgs.legacyPackages."${system}";
      project = import ./project.nix {
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
