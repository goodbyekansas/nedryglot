{ base, lib, checkHook, symlinkJoin, gitignoreFilter, gitignoreSource }:
pythonVersionName: pythonVersion:
args@{ name
, version
, src
, srcExclude ? [ ]
, preBuild ? ""
, format ? "setuptools"
, setuptoolsLibrary ? false
, doStandardTests ? true
, ...
}:
let
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
      srcIgnored = gitignoreFilter src;
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
        } else gitignoreSource args.src;

  attrs = builtins.removeAttrs args [ "srcExclude" "shellInputs" "targetSetup" "docs" "docsConfig" ];

  # Aside from propagating dependencies, buildPythonPackage also injects
  # code into and wraps executables with the paths included in this list.
  # Items listed in install_requires go here
  propagatedBuildInputs = resolveInputs "propagatedBuildInputs" attrs.propagatedBuildInputs or [ ];

  pythonPackageArgs = (attrs // {
    inherit version format preBuild doStandardTests pythonVersion propagatedBuildInputs;
    src = if lib.isStorePath src then src else filteredSrc;
    pname = name;

    # Don't install dependencies with pip, let nix handle that
    preInstall = ''
      pipInstallFlags+=('--no-deps')
    '';

    # Dependencies needed for running the checkPhase. These are added to nativeBuildInputs when doCheck = true.
    # Items listed in tests_require go here.
    checkInputs = (
      resolveInputs "checkInputs" attrs.checkInputs or [ ]
    )
    ++ [ (checkHook src pythonPkgs) ]
    ++ (builtins.map (input: pythonPkgs."types-${input.pname or input.name}" or null) (builtins.filter lib.isDerivation propagatedBuildInputs))
    ++ (lib.optional (format == "setuptools") pythonPkgs.types-setuptools);

    # Build-time only dependencies. Typically executables as well
    # as the items listed in setup_requires
    nativeBuildInputs = resolveInputs "nativeBuildInputs" attrs.nativeBuildInputs or [ ];

    # Build and/or run-time dependencies that need to be be compiled
    # for the host machine. Typically non-Python libraries which are being linked.
    buildInputs = resolveInputs "buildInputs" attrs.buildInputs or [ ];

    passthru = {
      shellInputs = (resolveInputs "shellInputs" args.shellInputs or [ ])
        ++ [ pythonPkgs.python-lsp-server pythonPkgs.pylsp-mypy pythonPkgs.pyls-isort ];
      inherit pythonPackageArgs;
    } // attrs.passthru or { };

    dontUseSetuptoolsCheck = true;

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
      variables = (rec {
        inherit version;
        pname = name;
        mainPackage = lib.toLower (builtins.replaceStrings [ "-" " " ] [ "_" "_" ] name);
        entryPoint = if setuptoolsLibrary then "{}" else "{\\\"console_scripts\\\": [\\\"${name}=${mainPackage}.main:main\\\"]}";
      } // args.targetSetup.variables or { });
      variableQueries = ({
        desc = "✍️ Write a short description for your component:";
        author = "🤓 Enter author name:";
        email = "📧 Enter author email:";
        url = "🏄 Enter author website url:";
      } // args.targetSetup.variableQueries or { });
      initCommands = "black .";
    });

    shellCommands = base.mkShellCommands name ({
      check = {
        script = ''eval ''${installCheckPhase:-echo "$name does not define an installCheckPhase"}'';
        description = "Run lints and tests.";
        show = attrs.doCheck or true;
      };
      format = {
        script = "black . && isort .";
        description = "Format the code.";
      };
      build = {
        script = ''eval $buildPhase'';
        show = false;
      };
      show-generated-config = {
        script = "$1 --print-generated-config";
        args = "<linter>";
        description = ''
          Show the config Nedryland has generated for a linter, one of:
          black, coverage, flake8, isort, mypy, pylint, pytest'';
      };
    } // attrs.shellCommands or { });
  });
in
pythonPkgs.buildPythonPackage pythonPackageArgs
