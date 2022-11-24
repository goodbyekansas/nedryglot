{ base
, buildPackages
, lib
, pkgs
, removeReferencesTo
, rootCallPackage
, symlinkJoin
, hostTriple
, buildTriple
}:

attrs@{ name
, componentTargetName
, srcExclude ? [ ]
, extraChecks ? ""
, buildFeatures ? [ ]
, testFeatures ? [ ]
, shellHook ? ""
, warningsAsErrors ? true
, filterCargoLock ? false
, ...
}:
let
  # "Compiler type" dependencies, buildPlatform = hostPlatform != targetPlatform
  # host = the platform that the resulting binary will run on (i.e. the host platform of
  # the produced artifact, not our host platform)
  # build = the platform we are building on
  inherit (buildPackages) rustfmt rust-analyzer clippy rustc cargo cacert callPackage;
  # The target stdenv for the new derivation has buildPlatform != hostPlatform
  inherit (pkgs) stdenv;
  # rustPlaform in buildPackages works like stdenv (has targetOffset -1 for stdenv).
  rustPlatform = buildPackages.makeRustPlatform { inherit stdenv rustc cargo; };

  # wrap resolveInputs to make it possible for all inputs to be a function
  # accepting the spliced package set.
  resolveInputs = name: inputType: searchFor: inputs:
    base.resolveInputs name inputType searchFor (
      if builtins.isFunction inputs then
        inputs pkgs
      else
        inputs
    );

  buildInputs = resolveInputs name "buildInputs" [ componentTargetName "rust" ] attrs.buildInputs or [ ];
  propagatedBuildInputs = resolveInputs name "propagatedBuildInputs" [ componentTargetName "rust" ] attrs.propagatedBuildInputs or [ ];
  shellInputs = resolveInputs name "shellInputs" [ componentTargetName "rust" ] attrs.shellInputs or [ ];
  nativeBuildInputs = resolveInputs name "nativeBuildInputs" [ componentTargetName "rust" ] attrs.nativeBuildInputs or [ ];
  checkInputs = resolveInputs name "checkInputs" [ componentTargetName "rust" ] attrs.checkInputs or [ ];

  vendor = callPackage ./vendor.nix {
    inherit name buildInputs propagatedBuildInputs;
    extraCargoConfig = attrs.extraCargoConfig or "";
  };

  getFeatures = features:
    if (builtins.length features) == 0 then
      ""
    else
      ''--features "${(builtins.concatStringsSep " " features)}"'';

  safeAttrs = builtins.removeAttrs attrs [
    "extraChecks"
    "testFeatures"
    "buildFeatures"
    "srcExclude"
    "shellInputs"
    "docs"
    "componentTargetName"
    "buildInputs"
    "propagatedBuildInputs"
    "nativeBuildInputs"
    "checkInputs"
  ];

  # cross compilation settings
  ccForBuild = "${buildPackages.stdenv.cc.targetPrefix}cc";
  cxxForBuild = "${buildPackages.stdenv.cc.targetPrefix}c++";
  linkerForBuild = ccForBuild;

  ccForHost = "${stdenv.cc.targetPrefix}cc";
  cxxForHost = "${stdenv.cc.targetPrefix}c++";
  linkerForHost = ccForHost;

  runner = rootCallPackage ./build-platform-runner.nix { buildPlatform = buildTriple; };
in
base.mkDerivation
  (
    safeAttrs // {
      inherit stdenv propagatedBuildInputs buildInputs runner checkInputs;
      shellCommands = {
        cargo = {
          script = ''
            subcommand="$1"
            if [ $# -gt 0 ] && ([ "$subcommand" == "test" ] || [ "$subcommand" == "clippy" ]) ; then
              shift
              command cargo "$subcommand" ${getFeatures testFeatures} "$@"
            elif [ $# -gt 0 ] && ([ "$subcommand" == "build" ] || [ "$subcommand" == "run" ]) ; then
              shift
              command cargo "$subcommand" ${getFeatures buildFeatures} "$@"
            else
              command cargo "$@"
            fi
          '';
          show = false;
        };
        run = {
          script = ''cargo run "$@"'';
          description = "Run the application.";
          args = "args ...";
        };
        format = {
          script = ''cargo fmt'';
          description = "Format the code.";
        };
        debug = {
          script = ''RUST_DEBUG=1 "$@"'';
          description = "Run a command with RUST_DEBUG set.";
          args = "command args ...";
        };
        check = {
          script = ''
            NIX_LOG_FD=/dev/null
            phases="checkPhase lintPhase"
            if [ -n "''${crossCheckPhase:-}" ]; then
              phases+=" crossCheckPhase"
            fi
            genericBuild
          '';
          description = "Runs cargo check, clippy and fmt.";
        };
      } // safeAttrs.shellCommands or { };
      strictDeps = true;
      disallowedReferences = [ vendor ];
      srcFilter = path: type: !(type == "directory" && baseNameOf path == "target")
      && !(type == "directory" && baseNameOf path == ".cargo")
      && !(filterCargoLock && type == "regular" && baseNameOf path == "Cargo.lock")
      && !(builtins.any (pred: pred path type) srcExclude);
      vendoredDependencies = vendor;

      nativeBuildInputs = [
        cacert
        removeReferencesTo
        vendor
      ]
      ++ (builtins.attrValues rustPlatform.rust)
      ++ nativeBuildInputs;

      lintInputs = [
        clippy
        rustfmt
      ];

      passthru = { shellInputs = (shellInputs ++ [ rust-analyzer ]); };

      depsBuildBuild = [ buildPackages.stdenv.cc runner ]
      ++ lib.optionals stdenv.buildPlatform.isDarwin [
        # this is actually not always needed but life is
        # too short to figure out when so let's always
        # add it
        buildPackages.darwin.apple_sdk.frameworks.Security
      ];

      configurePhase = attrs.configurePhase or ''
        runHook preConfigure
        if [ -z "$IN_NIX_SHELL" ]; then
          sed -i '/\[patch\.nix\]/,/^[.*]$/d' Cargo.toml
        fi
        export CARGO_HOME=$NIX_BUILD_TOP
        export RUSTFLAGS="$RUSTFLAGS --remap-path-prefix $NIX_BUILD_TOP=build-root"
        runHook postConfigure
      '';

      buildPhase = attrs.buildPhase or ''
        runHook preBuild
        cargo build --release ${getFeatures buildFeatures}
        runHook postBuild
      '';

      lintPhase = attrs.lintPhase or  ''
        runHook preLint
        cargo fmt -- --check
        cargo clippy ${getFeatures testFeatures}
        runHook postLint
      '';

      checkPhase = attrs.checkPhase or ''
        runHook preCheck
        cargo test ${getFeatures testFeatures} --release
        ${extraChecks}
        runHook postCheck
      '';

      # The binary we built will be full of paths pointing to the nix store.
      # Nix thinks it is doing us a favour by automatically adding dependencies
      # by finding store paths in the binary. We strip these store paths so
      # Nix won't find them.
      preFixup = ''
        find $out -type f -exec remove-references-to -t ${vendor} '{}' +
      ''
      # rustLibSrc is not required for rustPlatform
      + (if rustPlatform.rust.rustc ? src then
        "find $out -type f -exec remove-references-to -t ${rustPlatform.rustLibSrc} '{}' +"
      else "");

      targetSetup = base.mkTargetSetup {
        name = attrs.targetSetup.name or name;
        typeName = "rust";
        markerFiles = attrs.targetSetup.markerFiles or [ ] ++ [ "Cargo.toml" ];
        # Right now we only have .gitignore in here because of
        # https://github.com/rust-lang/cargo/issues/6357
        # but this means that we can add other files as well if we want to
        templateDir = symlinkJoin {
          name = "rust-component-template";
          paths = (
            lib.optional (attrs ? targetSetup.templateDir) attrs.targetSetup.templateDir
          ) ++ [ ./component-template ];
        };
        showTemplate = attrs.targetSetup.showTemplate or false;
        variables =
          let
            cfg = base.parseConfig {
              key = "components";
              structure = {
                author = null;
                email = null;
              };
            };
          in
          ({
            cargoLock = if filterCargoLock then "Cargo.lock" else "#Cargo.lock";
            CARGO_NAME = cfg.author;
            CARGO_EMAIL = cfg.email;
          } // attrs.targetSetup.variables or { });
        initCommands = ''cargo init --name ${name}
        ${attrs.targetSetup.initCommands or ""}'';
      };

      shellHook = ''
        runHook preShell
        ${shellHook}
        runHook postShell
      '';

      CARGO_BUILD_TARGET = hostTriple;

    } // (
      let
        flagList = lib.optional (attrs ? RUSTFLAGS) attrs.RUSTFLAGS
        ++ lib.optional warningsAsErrors "-D warnings"
        ++ lib.optional (stdenv.hostPlatform.isWasi) "-Clinker-flavor=gcc";
      in
      lib.optionalAttrs (flagList != [ ]) {
        RUSTFLAGS = builtins.concatStringsSep " " flagList;
      }
    ) // (
      if hostTriple != buildTriple then
        let
          hostTripleEnvVar = lib.toUpper (builtins.replaceStrings [ "-" ] [ "_" ] hostTriple);
          buildTripleEnvVar = lib.toUpper (builtins.replaceStrings [ "-" ] [ "_" ] buildTriple);
        in
        {
          # cross-things
          "CARGO_TARGET_${hostTripleEnvVar}_LINKER" = "${linkerForHost}";
          "CC_${hostTripleEnvVar}" = "${ccForHost}";
          "CXX_${hostTripleEnvVar}" = "${cxxForHost}";

          "CARGO_TARGET_${buildTripleEnvVar}_LINKER" = "${linkerForBuild}";
          "CC_${buildTripleEnvVar}" = "${ccForBuild}";
          "CXX_${buildTripleEnvVar}" = "${cxxForBuild}";
        } else { }
    )
  )
