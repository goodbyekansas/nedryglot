{ base, protobuf, tonicBuildVersion, makeSetupHook }:
let
  changeTonicBuildVersionHook = makeSetupHook
    {
      name = "changeTonicBuildVersion";
      substitutions = {
        inherit tonicBuildVersion;
      };
    } ./changeTonicBuildVersion.sh;
in
base.languages.rust.mkClient {
  name = "rust-protobuf-compiler";
  src = ./.;
  PROTOC = "${protobuf}/bin/protoc";
  nativeBuildInputs = [ changeTonicBuildVersionHook ];
  buildInputs = with base.languages.rust; [ crates.prost-build crates.structopt crates.tonic-build ];
}
