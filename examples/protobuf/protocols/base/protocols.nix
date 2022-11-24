{ base }:
base.languages.protobuf.mkModule {
  name = "base";
  version = "1.0.0";
  src = ./.;
  languages = [ base.languages.python base.languages.rust ];
}
