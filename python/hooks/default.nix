{ makeSetupHook
, writeTextFile
, pkgs
, bat
, findutils
, lib
, runtimeShell
, defaultCheckPhase
, configs
, ruff
}:
let
  generateConfigurationRunner =
    { toolDerivation
    , key
    , config
    , toolName ? toolDerivation.pname or toolDerivation.name
    , configFlag ? null
    , configEnvVar ? null
    , extraArgs ? ""
    , files ? [ ]
    , customExecution ? null
    ,
    }:
    let
      remove = builtins.foldl' (acc: cur: "${acc} ${cur}") ""
        (builtins.map (file: "${file.key}:${file.path}=${file.removeField}")
          (builtins.filter
            (file: builtins.isAttrs file && file ? removeField)
            files));

      py = if lib.versionAtLeast lib.version "23.05pre-git" then pkgs.python3 else pkgs.python310;
      execution =
        if customExecution == null then
          let
            cfgEnvVar =
              if configEnvVar != null then
                "${configEnvVar}=\"$config_file\" "
              else
                "";

            cfgFlag =
              if configFlag != null then
                "${configFlag} \"$config_file\""
              else
                "";
          in
          "${cfgEnvVar}${toolDerivation}/bin/${toolName} ${cfgFlag} \"$@\" ${extraArgs}"
        else
          customExecution;
    in
    writeTextFile {
      name = "${toolName}-with-nedryglot-cfg";
      executable = true;
      text = ''
        #!${runtimeShell}
        config_file=$(mktemp --tmpdir -d lint-configs-XXXX)/${config}
        export PYTHONPATH=''${PYTHONPATH:-}:${py.pkgs.toml}/${py.sitePackages}

        ${py}/bin/python \
          ${./config-merger.py} \
          --tool "${key}" \
          ${if remove != "" then "--remove-fields ${remove}" else ""} \
          --files ${builtins.concatStringsSep " " (
              builtins.map (file:
                if builtins.isPath file.path then
                  "${file.path}=${file.key}"
                else
                  "\"\${componentDir:-.}/${file.path}=${file.key}\""
              )
              (
                builtins.map
                  (path: if builtins.isAttrs path then path else {inherit key path;})
                  files
              )
          )} \
          --out-file="$config_file"


        if [[ $@ =~ "--print-generated-config-path" ]]; then
          echo "$config_file"
          exit 0
        fi

        if [[ $@ =~ "--print-generated-config" ]]; then
          ${bat}/bin/bat "$config_file"
          exit 0
        fi

        ${execution}
      '';
      destination = "/bin/${toolName}";
    };

  blackWithConfig = toolDerivation: generateConfigurationRunner {
    inherit toolDerivation;
    key = "tool.black";
    config = "black.toml";
    configFlag = "--config";
    files = [
      "pyproject.toml"
      { path = "setup.cfg"; key = "black"; }
    ] ++
    (lib.optional (configs ? black) configs.black)
    ++ [
      ./config/black.toml
    ];
  };

  ruffWithConfig = toolDerivation: generateConfigurationRunner {
    inherit toolDerivation;
    # Ruff can only take the config argument for the sub commands
    # check and format which is kind of annoying.
    customExecution = ''
      configArgs=""
      if [[ ! " $* " =~ [[:blank:]](rule|config|linter|clean|version|help)[[:blank:]] ]]; then
        configArgs="--config $config_file"
      fi

      ${toolDerivation}/bin/ruff "$@" $configArgs
    '';
    key = "";
    config = "ruff.toml";
    files = [
      { path = "pyproject.toml"; key = "tool.ruff"; }
      "ruff.toml"
      ".ruff.toml"
    ] ++
    (lib.optional (configs ? ruff) configs.ruff)
    ++ [
      { path = ./config/ruff.toml; key = "tool.ruff"; }
    ];
  };

  coverageWithConfig = toolDerivation: generateConfigurationRunner {
    inherit toolDerivation;
    key = "tool.coverage";
    config = "coverage.toml";
    configEnvVar = "COVERAGE_RCFILE";
    files = [
      { path = ".coveragerc"; key = "coverage"; }
      { path = "setup.cfg"; key = "tool:coverage"; }
      { path = "tox.ini"; key = "tool:coverage"; }
      "pyproject.toml"
    ] ++
    (lib.optional (configs ? coverage) configs.coverage)
    ++ [
      ./config/coverage.toml
    ];
  };

  flake8WithConfig = toolDerivation: generateConfigurationRunner {
    inherit toolDerivation;
    key = "flake8";
    config = "flake8.ini";
    configFlag = "--config";
    files = [
      ".flake8"
      "setup.cfg"
      "tox.ini"
    ] ++
    (lib.optional (configs ? flake8) configs.flake8)
    ++ [
      { path = ./config/flake8.toml; key = "tool.pycodestyle"; }
      { path = ./config/flake8.toml; key = "tool.flake8"; }
    ];
  };

  isortWithConfig = toolDerivation: generateConfigurationRunner {
    inherit toolDerivation;
    configFlag = "--settings-file";
    extraArgs = "--src-path .";
    key = "isort";
    config = "isort.ini";
    files = [
      ".isort.cfg"
      { path = "pyproject.toml"; key = "tool.isort"; }
      "setup.cfg"
      "tox.ini"
      ".editorconfig"
    ] ++
    (lib.optional (configs ? isort) configs.isort)
    ++ [
      { path = ./config/isort.toml; key = "tool.isort"; }
    ];
  };

  mypyWithConfig = toolDerivation: generateConfigurationRunner {
    inherit toolDerivation;
    configFlag = "--config-file";
    key = "mypy";
    config = "mypy.ini";
    files = [
      "mypy.ini"
      ".mypy.ini"
      { path = "pyproject.toml"; key = "tool.mypy.overrides"; }
      { path = "pyproject.toml"; key = "tool.mypy"; removeField = "tool.mypy.overrides"; }
      "setup.cfg"
    ] ++
    (lib.optional (configs ? mypy) configs.mypy)
    ++ [
      { path = ./config/mypy.toml; key = "tool.mypy"; }
    ];
  };

  pylintWithConfig = toolDerivation: generateConfigurationRunner {
    inherit toolDerivation;
    configFlag = "--rcfile";
    config = "pylint.toml";
    key = "tool.pylint";
    files = [
      { path = "pylintrc"; key = ""; }
      { path = ".pylintrc"; key = ""; }
      "pyproject.toml"
    ] ++
    (lib.optional (configs ? pylint) configs.pylint)
    ++ [
      (if lib.versionAtLeast toolDerivation.version "2.14" then
        ./config/pylint2_14.toml
      else
        ./config/pylint.toml)
    ];
  };

  pytestWithConfig = toolDerivation: generateConfigurationRunner {
    inherit toolDerivation;
    configFlag = "-c";
    config = "pytest.ini";
    key = "pytest";
    files = [
      "pytest.ini"
      { path = "pyproject.toml"; key = "tool.pytest.ini_options"; }
      { path = "pylintrc.toml"; key = "tool.pytest.ini_options"; }
      "tox.ini"
      { path = "setup.cfg"; key = "tool:pytest"; }
    ] ++
    (lib.optional (configs ? pytest) configs.pytest)
    ++ [
      { path = ./config/pytest.toml; key = "tool.pytest.ini_options"; }
    ];
    extraArgs = "--rootdir=./";
  };
  depsAttr = if lib.versionOlder lib.version "23.05pre-git" then "deps" else "propagatedBuildInputs";
in
{
  check = _: pythonPkgs:
    makeSetupHook
      {
        name = "check-hook";
        substitutions = {
          inherit defaultCheckPhase;
        };

        "${depsAttr}" = with pythonPkgs; [
          findutils
          (coverageWithConfig coverage)
          (flake8WithConfig flake8)
          (isortWithConfig isort)
          (mypyWithConfig mypy)
          (pylintWithConfig pylint)
          (pytestWithConfig pytest)
          (ruffWithConfig ruff)
          # pytest is also useful as a module in PYTHONPATH for fixtures and such
          pytest
        ]
        ++
        lib.optional
          (with pythonPkgs.python.stdenv;
          !(isAarch64 && isDarwin && lib.versionOlder lib.version "22.11pre-git"))
          (blackWithConfig black);
      } ./check.bash;
}
