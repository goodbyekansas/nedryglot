{ base, name, version, protoSources, python3, protoInputs }:
let
  protoIncludePaths = builtins.map (pi: pi.protobuf) protoInputs;
in
base.mkDerivation {
  inherit protoSources protoIncludePaths;
  name = "python-${name}";
  src = ./protobuf;
  packageName = builtins.replaceStrings [ "-" ] [ "_" ] name;
  nativeBuildInputs = with python3.pkgs; [ grpcio-tools setuptools ];
  phases = [ "unpackPhase" "buildPhase" "installPhase" ];
  buildPhase = ''

    shopt -s globstar extglob nullglob

    substituteInPlace ./pyproject.toml --subst-var-by packageName ${name} --subst-var-by version ${version}
    includes=""
    for p in $protoIncludePaths; do
      includes+=" -I $p"
    done

    python -m grpc_tools.protoc \
        -I "$protoSources" \
        $includes \
        --python_out=. \
        --pyi_out=. \
        --grpc_python_out=. \
        "$protoSources"/**/*.proto

    # protoc does not add __init__.py files, so let's do so
    find . -type d -exec touch {}/__init__.py \;
    find . -type d -exec touch {}/py.typed \;

    find . \
      -mindepth 1 \
      -maxdepth 1 \
      -type d \
      -exec \
        sh -c 'echo "$(basename {}) = [\"**/*.pyi\", \"**/py.typed\", \"py.typed\", \"*.pyi\"]" >>./pyproject.toml' \;
  '';

  installPhase = ''
    mkdir -p $out
    cp -r . $out
  '';
}
