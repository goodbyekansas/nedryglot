{ base, protobuf, protoc-gen-doc, languages, grpcurl, runCommand, writeScriptBin }:
let
  allLanguages = builtins.attrValues languages;
in
{
  name = "protobuf";
  emoji = "📠";
  description = ''

    Protocol buffers are Google's language-neutral, platform-neutral,
    extensible mechanism for serializing structured data – think XML, but
    smaller, faster, and simpler.
  '';

  mkModule =
    { name
    , src
    , version
    , languages ? allLanguages
      # TODO: Support more than gRPC?
    , includeServices ? false
    , protoInputs ? [ ]
    }:
    let
      langs = builtins.listToAttrs
        (builtins.map
          (lang:
            {
              inherit (lang) name;
              value =
                lang.fromProtobuf (
                  builtins.intersectAttrs
                    (
                      builtins.functionArgs lang.fromProtobuf
                    )
                    {
                      inherit name languages version includeServices protoInputs;
                      protoSources = src;
                    }
                );
            })
          (builtins.filter (value: value ? fromProtobuf) languages)
        );
      protoset = runCommand
        "generate-protoset"
        { }
        ''
          ${protobuf}/bin/protoc \
            --proto_path=${src} \
            --descriptor_set_out="$out" \
            --include_imports \
            ${src}/**/*.proto
        '';

      grpcurlWrapped = writeScriptBin "grpcurl" ''
        case "$1" in
          *help)
            ${grpcurl}/bin/grpcurl --help
            exit 0;;

          list|describe)
            ${grpcurl}/bin/grpcurl -protoset "${protoset}" "$@"
            exit;;
        esac
        ${grpcurl}/bin/grpcurl -protoset "${protoset}" -plaintext "$@"
      '';
    in
    base.mkComponent (langs // {
      inherit name;
      _default = src;
      protobuf = src;
      tools = grpcurlWrapped;
      docs.api = base.mkDerivation {
        name = "${name}-generated-docs";
        inherit src;
        protoIncludePaths = builtins.map (pi: pi.protobuf) protoInputs;
        nativeBuildInputs = [ protobuf protoc-gen-doc ];
        builder = builtins.toFile "builder.sh" ''
          source $stdenv/setup
          includes=""
          for p in $protoIncludePaths; do
            includes+=" -I $p"
          done
          mkdir -p "$out/share/doc/${name}/api"
          protoc --proto_path=$src $includes --doc_out="$out/share/doc/${name}/api/" --doc_opt=html,index.html $(find $src -name "*.proto" -print)
        '';
      };
    });
}
