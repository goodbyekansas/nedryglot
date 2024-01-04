let
  inner =
    args@{ base
    , callPackage
    , cargo
    , clippy
    , jq
    , lib
    , j2cli
    , pkgs
    , python3
    , rustc
    , rust-analyzer
    , rust
    , rustfmt
    , stdenv
    , symlinkJoin
    , fetchurl
    , tonicVersion ? "0.10.2"
    , xdg-utils
    , crates ? null
    , crossTargets ? { }
    , extraAttrs ? { }
    }:
    let
      # the toRustTarget function in nixpkgs handles wasi incorrectly, patch it here
      toRustTarget = target:
        builtins.replaceStrings [ "wasm32-unknown-wasi" ] [ "wasm32-wasi" ] (rust.toRustTarget target);
      buildTriple = toRustTarget stdenv.hostPlatform;

      mkCrossTarget =
        { name ? pkgs.stdenv.hostPlatform.system
        , rustToolset ? null
        , pkgs
        , output ? null
        , attrs ? _: { }
        }:
        let
          rustToolsetArgs = lib.optionalAttrs (rustToolset != null) {
            buildPackages = pkgs.buildPackages // {
              inherit (rustToolset) rustfmt rust-analyzer clippy cargo rustc;
            };
          };
          hostTriple = toRustTarget pkgs.stdenv.hostPlatform;
        in
        {
          inherit name attrs hostTriple;
          mkPackage = pkgs.callPackage ./package.nix ({
            inherit base hostTriple buildTriple python3;
          } // rustToolsetArgs);
        } // lib.optionalAttrs (output != null) { inherit output; };

      crossTargets' = {
        # "rust" is always the default target.
        rust =
          mkCrossTarget {
            inherit pkgs;
            rustToolset = mkRustToolset {
              inherit rustfmt rust-analyzer clippy cargo rustc;
            };
          };
      } // crossTargets;

      toDocs = targetSpecs: pkgAttrs@{ name, ... }:
        let
          docDrvs = builtins.mapAttrs
            (componentTargetName: targetSpec:
              targetSpec.mkPackage (pkgAttrs // (targetSpec.attrs pkgAttrs) // {
                inherit componentTargetName;
                name = "${name}-api-reference";
                dontFixup = true;
                doCheck = false;
                buildPhase = "cargo doc --workspace --no-deps --all-features";
                installPhase = ''
                  export outPath=$(realpath -m $out/share/doc/${name}/api)
                  crateNames=$(cargo metadata --format-version=1 --no-deps | ${jq}/bin/jq -r '.packages[].name')
                  mkdir -p $outPath
                  cp -r target/*/doc/. $outPath
                  for crate in $crateNames; do
                    mv $outPath/''${crate//-/_} $outPath/''${crate//-/_}-${targetSpec.hostTriple}
                  done
                  echo $crateNames > $outPath/crate_names
                '';
              })
            )
            targetSpecs;
        in
        symlinkJoin {
          name = "${name}-api-reference";
          paths = builtins.attrValues docDrvs;
          # Create an index HTML page for all targets. If there is only one target, the index
          # page will only contain a redirect to the single target (this is handled in the
          # html template)
          targets = lib.mapAttrsToList (_targetName: targetSpec: targetSpec.hostTriple) targetSpecs;
          passthru = docDrvs;
          postBuild = ''
            crateNames=$(cat $out/share/doc/${name}/api/crate_names)
            echo "title: ${name}" > data.yml
            echo "links:" >> data.yml
            for crateName in $crateNames; do
              for targetName in $targets; do
                echo "  - name: $crateName ($targetName)" >> data.yml
                echo "    href: ''${crateName//-/_}-$targetName" >> data.yml
              done
            done
            ${j2cli}/bin/j2 ${./docs/index.html} data.yml -o $out/share/doc/${name}/api/index.html
          '';
          shellInputs = [
            xdg-utils
            (base.mkShellCommands "${name}-api-reference" {
              build = ''
                cd target
                rm -rf docs
                out=./docs genericBuild
              '';
              run = ''
                build
                xdg-open target/docs/share/doc/${name}/api/index.html >/dev/null
              '';
            })
          ];
        };

      toPackages = targetSpecs: pkgPostHook: pkgAttrs: builtins.mapAttrs
        (componentTargetName: targetSpec:
          pkgPostHook
            (targetSpec.mkPackage
              (pkgAttrs // (targetSpec.attrs pkgAttrs) // { inherit componentTargetName; }))
        )
        targetSpecs;

      mkComponentWith = componentFactory: packagePostHook:
        attrs@ { name, deployment ? { }, ... }:
        let
          pkgAttrs = builtins.removeAttrs attrs [ "deployment" ];
          targets = toPackages crossTargets' packagePostHook pkgAttrs;
          apiDocs = toDocs crossTargets' pkgAttrs;
        in
        componentFactory ({
          inherit deployment name;
          _default = targets.rust;
        } // targets // {
          docs = {
            api = apiDocs;
          } // (attrs.docs or { });
        });

      mkRustToolset = { rustc, cargo, clippy, rust-analyzer, rustfmt }: { inherit rustc cargo clippy rust-analyzer rustfmt; };

      overrideAttrs = attrs: inner (args // attrs);

      overrideCrossTargets = f: inner (args // {
        crossTargets = crossTargets // (f crossTargets);
      });

      toApplication = package:
        package.overrideAttrs (
          oldAttrs: {
            installPhase =
              let
                executableName = package.executableName or package.meta.name;
              in
              ''
                ${oldAttrs.installPhase or ""}
                mkdir -p $out/bin
                cp target/''${CARGO_BUILD_TARGET:-}/release/${executableName}${package.stdenv.hostPlatform.extensions.executable} $out/bin
              '';
            # TODO: Should be a shell command
            shellHook = ''
              ${oldAttrs.shellHook or ""}
              ${builtins.replaceStrings [ "-" ] [ "_" ] package.executableName or package.meta.name}() {
                command cargo run -- "$@"
              }
            '';
          }
        );

      toLibrary = package:
        package.overrideAttrs (
          oldAttrs: {

            buildPhase = ''
              runHook preBuild
              cargo package --no-verify --no-metadata
              runHook postBuild
            '';

            installPhase = ''
              runHook preInstall
              ${oldAttrs.installPhase or ""}
              mkdir -p $out

              for crate in target/package/*.crate; do
                tar -xzf $crate -C $out
                echo "{\"files\":{},\"package\":\"$(sha256sum $crate | grep -E -o '^(\w*)')\"}" >$out/"$(basename "''${crate//.crate/}")"/.cargo-checksum.json
              done
              runHook postInstall
            '';

          }
        );

      mkLibrary = attrs:
        mkComponentWith base.mkLibrary toLibrary (attrs // {
          filterCargoLock = true;
        });

      addAttributes = f: inner (args // {
        extraAttrs = extraAttrs // (f extraAttrs);
      });

      fetchCrate = { name, version, sha256, deps ? [ ] }:
        stdenv.mkDerivation rec{
          inherit version;
          pname = name;
          propagatedBuildInputs = deps;
          dontBuild = true;
          dontConfigure = true;
          dontPatchShebangs = true;
          dontShrink = true;
          dontStrip = true;
          src = fetchurl {
            name = "${name}.tar.gz";
            inherit sha256;
            url = "https://crates.io/api/v1/crates/${name}/${version}/download";
          };
          installPhase = ''
            mkdir $out
            cp -r . $out
            echo "{\"files\":{},\"package\":\"$(sha256sum ${src} | grep -E -o '^(\w*)')\"}" >$out/.cargo-checksum.json
          '';
        };

      crates' = if crates == null then import ./default-crates.nix fetchCrate else crates;
    in
    extraAttrs // {
      inherit overrideAttrs mkRustToolset mkCrossTarget overrideCrossTargets toApplication toLibrary mkLibrary addAttributes toRustTarget fetchCrate;
      crates = crates';
      crossTargets = crossTargets' // {
        override = overrideCrossTargets;
      };
      name = "rust";
      emoji = "🦀";
      description = ''
        A language empowering everyone to build reliable and efficient
        software.
      '';
      mkComponent = attrs@{ nedrylandType, ... }:
        let
          attrs' = builtins.removeAttrs attrs [ "nedrylandType" ];
        in
        mkComponentWith (attrs: base.mkComponent (attrs // { inherit nedrylandType; })) (su: su) attrs';

      combineInputs = first: second:
        let
          firstFunc = if builtins.isList first then (_: first) else first;
          secondFunc = if builtins.isList second then (_: second) else second;
        in
        packages: firstFunc packages ++ (secondFunc packages);

      defaultVersion = { inherit rustc cargo; };

      mkClient = mkComponentWith base.mkClient toApplication;

      mkService = mkComponentWith base.mkService toApplication;

      fromProtobuf =
        { name
        , protoSources
        , version
        , includeServices
        , protoInputs
        }:
        let
          generatedCode = callPackage ./protobuf.nix
            {
              inherit
                base
                name
                protoSources
                version
                includeServices
                protoInputs
                tonicVersion
                crates;
              tonicBuildVersion = tonicVersion;
              pyToml = python3.pkgs.toml;
              tonicFeatures = [ "tls" "tls-roots" ];
            };
        in
        mkLibrary
          {
            inherit version;
            name = "${name}-rust-protobuf";
            src = generatedCode;
            propagatedBuildInputs = builtins.map (pi: pi.rust.rust) protoInputs
            ++ [ crates'.prost crates'.tempfile crates'.bytes ]
            ++ lib.optional includeServices crates'.tonic;

            # Disabling the check phase as we do not care about
            # formatting or testing generated code.
            doCheck = false;
          };
    };
in
inner
