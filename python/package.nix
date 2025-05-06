{ base, lib, checkHook, symlinkJoin }:
pythonVersionName: pythonVersion:
args@{ name
, version
, src
, srcExclude ? [ ]
, preBuild ? ""
, setuptoolsLibrary ? false
, doStandardTests ? true
, ...
}:
let
  gitignore = (import (builtins.fetchTarball {
    url = "https://github.com/hercules-ci/gitignore.nix/archive/a20de23b925fd8264fd7fad6454652e142fd7f73.tar.gz";
    sha256 = "sha256:07vg2i9va38zbld9abs9lzqblz193vc5wvqd6h7amkmwf66ljcgh";
  })) {
    lib = lib // (lib.optionalAttrs (! lib ? inPureEvalMode) {
      inPureEvalMode = ! builtins ? currentSystem;
    });
  };

  pythonPkgs = pythonVersion.pkgs;
  resolveInputs = typeName: inputs:
    builtins.filter
      (input:
        if input ? pythonVersion && input.pythonVersion ? pythonVersion && input.pythonVersion.pythonVersion != pythonVersion.pythonVersion then
          abort "The python package \"${name}\" uses python version ${pythonVersion.pythonVersion}, the dependency \"${input.name}\" uses incompatible python version ${input.pythonVersion.pythonVersion}."
        else true
      )
      (base.resolveInputs name typeName [ pythonVersionName ] (
        if builtins.isFunction inputs then
          (inputs pythonPkgs)
        else inputs
      ));

  customerFilter = src:
    let
      # IMPORTANT: use a let binding like this to memoize info about the git directories.
      srcIgnored = gitignore.gitignoreFilter src;
    in
    path: type:
      (srcIgnored path type) && !(builtins.any (pred: pred path type) srcExclude);
  filteredSrc =
    if srcExclude != [ ] then
      lib.cleanSourceWith
        {
          inherit (args) src;
          filter = customerFilter args.src;
          name = "${name}-source";
        } else gitignore.gitignoreSource args.src;

  attrs = builtins.removeAttrs args [ "srcExclude" "shellInputs" "targetSetup" "docs" "docsConfig" ];

  # Aside from propagating dependencies, buildPythonPackage also injects
  # code into and wraps executables with the paths included in this list.
  # Items listed in install_requires go here
  propagatedBuildInputs = resolveInputs "propagatedBuildInputs" attrs.propagatedBuildInputs or [ ];

  targetSetup = if (args ? targetSetup && lib.isDerivation args.targetSetup) then args.targetSetup else
  (base.mkTargetSetup {
    name = args.targetSetup.name or args.name;
    typeName = "python";
    markerFiles = args.targetSetup.markerFiles or [ ] ++ [ "setup.py" "setup.cfg" "pyproject.toml" ];
    templateDir = symlinkJoin {
      name = "python-component-template";
      paths = (
        lib.optional (args ? targetSetup.templateDir) args.targetSetup.templateDir
      ) ++ [ ./component-template ];
    };
    variables = rec {
      inherit version;
      pname = name;
      mainPackage = lib.toLower (builtins.replaceStrings [ "-" " " ] [ "_" "_" ] name);
      entryPoint = if setuptoolsLibrary then "" else "${name}=\\\"${mainPackage}.main:main\\\"";
    } // args.targetSetup.variables or { };
    variableQueries = {
      desc = "✍️ Write a short description for your component:";
      author = "🤓 Enter author name:";
      email = "📧 Enter author email:";
      url = "🏄 Enter author website url:";
    } // args.targetSetup.variableQueries or { };
    initCommands = ''
      ${if ! setuptoolsLibrary then "cat ${./main.py.in} >>$mainPackage/main.py" else ""}
      ruff format .
      ruff check --fix --unsafe-fixes .
    '';
  });

  pythonPackageArgs = attrs // {
    inherit version preBuild doStandardTests pythonVersion propagatedBuildInputs;
    src = if lib.isStorePath src then src else filteredSrc;
    pname = name;
    format = attrs.format or "pyproject";

    # Don't install dependencies with pip, let nix handle that
    preInstall = ''
      pipInstallFlags+=('--no-deps')
      ${attrs.preInstall or ""}
    '';

    nativeCheckInputs = resolveInputs "nativeCheckInputs" attrs.nativeCheckInputs or [ ];

    # Dependencies needed for running the checkPhase. These are added to buildInputs when doCheck = true.
    # Items listed in tests_require go here.
    checkInputs =
      let
        getTypePackageName = pkg: "types-${pkg.pname or pkg.name}";
      in
      (resolveInputs "checkInputs" attrs.checkInputs or [ ])
        ++ (builtins.map
        (input: pythonPkgs."${getTypePackageName input}")
        (builtins.filter
          (val:
            let
              typePackageName = getTypePackageName val;
              # Have to do this check some packages (type)
              # just throw exception instead of just being
              # removed.
              isValid = (builtins.hasAttr typePackageName pythonPkgs) &&
                (builtins.tryEval pythonPkgs."${typePackageName}").success;
            in
            lib.isDerivation val && isValid
          )
          propagatedBuildInputs)
      )
        ++ (lib.optional (attrs.format or "setuptools" == "setuptools") pythonPkgs.types-setuptools);

    # Build-time only dependencies. Typically executables as well
    # as the items listed in setup_requires
    nativeBuildInputs = resolveInputs "nativeBuildInputs" attrs.nativeBuildInputs or [ ]
      # make sure to add check hook here to get it before any shell inputs
      # in path
      ++ (lib.optional (attrs.doCheck or true) (checkHook src pythonPkgs));

    # Build and/or run-time dependencies that need to be be compiled
    # for the host machine. Typically non-Python libraries which are being linked.
    buildInputs = resolveInputs "buildInputs" attrs.buildInputs or [ ];

    passthru = {
      shellInputs = [
        pythonPkgs.python-lsp-server
        pythonPkgs.pylsp-mypy
        pythonPkgs.pyls-isort
        pythonPkgs.python-lsp-ruff
        targetSetup
      ]
      ++ args.shellInputs or [ ];
      inherit pythonPackageArgs;
    } // attrs.passthru or { };

    dontUseSetuptoolsCheck = true;

    shellCommands = base.mkShellCommands name ({
      check = {
        script = ''eval ''${installCheckPhase:-echo "$name does not define an installCheckPhase"}'';
        description = "Run lints and tests.";
        show = attrs.doCheck or true;
      };
      format = {
        script = "runFormat";
        description = "Format the code.";
      };
      build = {
        description = "Build the code";
        script = ''
          set +u
          phases="configurePhase ''${preBuildPhases:-} buildPhase" genericBuild
        '';
      };
      show-generated-config = {
        script = "$1 --print-generated-config";
        args = "<linter>";
        description = ''
          Show the config Nedryland has generated for a linter, one of:
          black, coverage, flake8, isort, mypy, pylint, pytest'';
      };
    } // (
      lib.optionalAttrs
        (! setuptoolsLibrary)
        {
          run = {
            script = ''python -m ${name}.main "$@"'';
            description = "Run the main module.";
          };
        })
    // attrs.shellCommands or { });
  };
in
pythonPkgs.buildPythonPackage pythonPackageArgs
