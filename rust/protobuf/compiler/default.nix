{ base, protobuf, tonicBuildVersion, makeSetupHook, crates }:
let
  changeTonicBuildVersionHook = makeSetupHook
    {
      name = "changeTonicBuildVersion";
      substitutions = {
        inherit tonicBuildVersion;
      };
    } ./changeTonicBuildVersion.sh;

  crates' = if crates == null then import ./crates.nix base.languages.rust.fetchCrate else crates;
in
base.languages.rust.mkClient {
  name = "rust-protobuf-compiler";
  src = ./.;
  PROTOC = "${protobuf}/bin/protoc";
  nativeBuildInputs = [ changeTonicBuildVersionHook ];
  buildInputs = [
    crates'.prost-build
    crates'.structopt
    crates'.tonic-build
  ];
}
