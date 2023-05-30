{ makeSetupHook, writeShellScriptBin, runCommandLocal, python310, bat, findutils, lib }:
let
  mergeConfigs = src: name: key: files:
    let
      remove = builtins.foldl' (acc: cur: "${acc} ${cur}") ""
        (builtins.map (file: "${file.key}:${file.path}=${file.removeField}")
          (builtins.filter
            (file: builtins.isAttrs file && file ? removeField)
            files));
    in
    runCommandLocal name { } ''
      export PYTHONPATH=''${PYTHONPATH:-}:${python310.pkgs.toml}/${python310.sitePackages}
      ${python310}/bin/python ${./config-merger.py} --tool "${key}" ${if remove != "" then "--remove-fields ${remove}" else ""} --files ${builtins.concatStringsSep " " (
        builtins.map (file:
          if builtins.isPath file.path then
            "${file.path}=${file.key}"
          else
            "${src}/${file.path}=${file.key}"
        )
        (
          builtins.map
            (path: if builtins.isAttrs path then path else {inherit key path;})
            files
        )
      )}
    '';

  generateConfigurationRunner =
    { toolDerivation
    , toolName ? toolDerivation.pname or toolDerivation.name
    , configFlag ? "--config"
    , config
    , extraArgs ? ""
    }:
    writeShellScriptBin toolName ''
      if [[ $@ =~ "--print-generated-config-path" ]]; then
        echo "${config}"
        exit 0
      fi

      if [[ $@ =~ "--print-generated-config" ]]; then
        ${bat}/bin/bat "${config}"
        exit 0
      fi

      ${toolDerivation}/bin/${toolName} ${configFlag} ${config} "$@" ${extraArgs}
    '';

  blackWithConfig = src: toolDerivation: generateConfigurationRunner {
    inherit toolDerivation;
    config = mergeConfigs src "black.toml" "black" [
      { path = "pyproject.toml"; key = "tool.black"; }
      "setup.cfg"
      { path = ./config/black.toml; key = "tool.black"; }
    ];
  };

  coverageWithConfig = src: toolDerivation: generateConfigurationRunner {
    inherit toolDerivation;
    configFlag = "--rcfile";
    config = mergeConfigs src "coverage.toml" "coverage" [
      ".coveragerc"
      { path = "setup.cfg"; key = "tool:coverage"; }
      { path = "tox.ini"; key = "tool:coverage"; }
      { path = "pyproject.toml"; key = "tool.coverage"; }
      { path = ./config/coverage.toml; key = "tool.coverage"; }
    ];
  };

  flake8WithConfig = src: toolDerivation: generateConfigurationRunner {
    inherit toolDerivation;
    config = mergeConfigs src "flake8.ini" "flake8" [
      ".flake8"
      "setup.cfg"
      "tox.ini"
      { path = ./config/flake8.toml; key = "tool.pycodestyle"; }
      { path = ./config/flake8.toml; key = "tool.flake8"; }
    ];
  };

  isortWithConfig = src: toolDerivation: generateConfigurationRunner {
    inherit toolDerivation;
    configFlag = "--settings-file";
    extraArgs = "--src-path .";
    config = mergeConfigs src "isort.ini" "isort" [
      ".isort.cfg"
      { path = "pyproject.toml"; key = "tool.isort"; }
      "setup.cfg"
      "tox.ini"
      ".editorconfig"
      { path = ./config/isort.toml; key = "tool.isort"; }
    ];
  };

  mypyWithConfig = src: toolDerivation: generateConfigurationRunner {
    inherit toolDerivation;
    configFlag = "--config-file";
    config = mergeConfigs src "mypy.ini" "mypy" [
      "mypy.ini"
      ".mypy.ini"
      { path = "pyproject.toml"; key = "tool.mypy.overrides"; }
      { path = "pyproject.toml"; key = "tool.mypy"; removeField = "tool.mypy.overrides"; }
      "setup.cfg"
      { path = ./config/mypy.toml; key = "tool.mypy"; }
    ];
  };

  pylintWithConfig = src: toolDerivation: generateConfigurationRunner {
    inherit toolDerivation;
    configFlag = "--rcfile";
    config = mergeConfigs src "pylint.toml" "pylint" [
      { path = "pylintrc"; key = ""; }
      { path = ".pylintrc"; key = ""; }
      { path = "pyproject.toml"; key = "tool.pylint"; }
      ({
        path =
          if lib.versionAtLeast toolDerivation.version "2.14" then
            ./config/pylint2_14.toml
          else
            ./config/pylint.toml;
        key = "tool.pylint";
      })
    ];
  };

  pytestWithConfig = src: toolDerivation: generateConfigurationRunner {
    inherit toolDerivation;
    configFlag = "-c";
    config = mergeConfigs src "pytest.ini" "pytest" [
      "pytest.ini"
      { path = "pyproject.toml"; key = "tool.pytest.ini_options"; }
      { path = "pylintrc.toml"; key = "tool.pytest.ini_options"; }
      "tox.ini"
      { path = "setup.cfg"; key = "tool:pytest"; }
      { path = ./config/pytest.toml; key = "tool.pytest.ini_options"; }
    ];
    extraArgs = "--rootdir=./";
  };
in
{
  check = src: pythonPkgs:
    makeSetupHook
      {
        name = "check-hook";
        deps = with pythonPkgs; [
          findutils
          (coverageWithConfig src coverage)
          (flake8WithConfig src flake8)
          (isortWithConfig src isort)
          (mypyWithConfig src mypy)
          (pylintWithConfig src pylint)
          (pytestWithConfig src pytest)
          # pytest is also useful as a module in PYTHONPATH for fixtures and such
          pytest
        ]
        ++
        lib.optional
          (with pythonPkgs.python.stdenv;
          !(isAarch64 && isDarwin && lib.versionOlder lib.version "22.11pre-git"))
          (blackWithConfig src black);
      } ./check.bash;
}
