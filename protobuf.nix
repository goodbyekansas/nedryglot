{ base, callPackage }:
{
  languages.protobuf = callPackage ./protobuf { inherit base; inherit (base) languages; };
}
