{ base, callPackage }:
{
  languages.protobuf = callPackage ./protobuf { inherit base; languages = base.languages; };
}
