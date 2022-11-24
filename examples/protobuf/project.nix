# Example project illustrating the protobuf generation functionality in Nedryland
{ nedryland, pkgs }:
let
  nedry = nedryland { inherit pkgs; };
in
nedry.mkProject {
  name = "protobuf-example";
  configFile = ./config.toml;
  components = { callFile }: {
    # create a proto module that depends on another one
    baseProtocols = callFile ./protocols/base/protocols.nix { };
    protocols = callFile ./protocols/ext/protocols.nix { };

    clients = {
      rust = callFile ./clients/rust/client.nix { };
      python = callFile ./clients/python/client.nix { };
    };
  };

  baseExtensions =
    let
      nedryglot = import ../../default.nix { };
    in
    [
      nedryglot.languages
      nedryglot.protobuf
    ];
}
