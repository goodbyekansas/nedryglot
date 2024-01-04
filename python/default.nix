{ base, callPackage, lib, python, pythonVersions ? { } }:
let
  pythons = pythonVersions // { inherit python; };
  defaultPythonName = "python";

  hooks = callPackage ./hooks { };

  mkPackage = callPackage ./package.nix { inherit base; checkHook = hooks.check; };

  mkDocs = callPackage ./docs.nix { inherit base; };

  addWheelOutput = pythonPackage:
    pythonPackage.overrideAttrs (_:
      {
        outputs = pythonPackage.outputs or [ "out" ] ++ [ "wheel" ];
        postInstall = ''
          ${pythonPackage.postInstall or ""}
          mkdir -p "${builtins.placeholder "wheel"}"
          cp dist/*.whl "${builtins.placeholder "wheel"}"
        '';
      }
    );

  mkComponentWith = componentFunc: postPackageFunc: extraArgs: attrs:
    let
      # Only build wheel if we have a format that builds a wheel. Duh.
      buildWheel = builtins.elem (attrs.format or "setuptools") [ "setuptools" "flit" "pyproject" ];
      attrsFn = if builtins.isFunction attrs then attrs else (_: attrs);
      args = builtins.functionArgs attrsFn;
      callPython = pythonVersion: overrides: (attrsFn (builtins.intersectAttrs args (pythonVersion.pkgs // overrides))) // extraArgs;
      packages =
        let
          makePkg = attrName: python: overrides: postPackageFunc python (mkPackage attrName python (callPython python overrides));
          pkg = attrName: python: makePkg attrName python { };
        in
        builtins.mapAttrs
          (k: p: (
            if buildWheel then
              (addWheelOutput (pkg k p)) // { override = attr: addWheelOutput (makePkg k p attr); }
            else
              (pkg k p) // { override = makePkg k p; }
          )
          )
          pythons;
      defaultPackage = builtins.getAttr defaultPythonName packages;
      defaultAttrs = callPython pythons.python { };

    in
    componentFunc ({
      inherit (defaultAttrs) name version;
      _default = defaultPackage;
      docs = (
        mkDocs
          ((defaultPackage.originalDrv or defaultPackage).pythonPackageArgs
            // lib.optionalAttrs (defaultAttrs ? docsConfig) { inherit (defaultAttrs) docsConfig; })
      )
      // defaultAttrs.docs or { };
    } // packages);
in
rec {
  name = "python";
  emoji = "🐍";
  description = ''
    Python is a programming language that lets you work quickly and
    integrate systems more effectively.
  '';
  inherit mkDocs addWheelOutput hooks;

  combineInputs = first: second:
    let
      firstFunc = if builtins.isList first then (_: first) else first;
      secondFunc = if builtins.isList second then (_: second) else second;
    in
    packages: firstFunc packages ++ (secondFunc packages);

  fromProtobuf = { name, version, protoSources, protoInputs }:
    (mkLibrary
      {
        inherit version;
        name = "${name}-python-protobuf";
        src = callPackage ./protobuf.nix { inherit base name version protoSources protoInputs; };
        propagatedBuildInputs = pypkgs: [ pypkgs.grpcio ] ++ builtins.map (pi: pi.python) protoInputs;
        doStandardTests = false; # We don't want to run our strict tests on generated code and stubs
      } // {
      __functor = self: { author, email }: self.overrideAttrs (_: {
        src = callPackage ./protobuf.nix { inherit base name version protoSources protoInputs author email; };
      });
    });

  defaultVersion = builtins.getAttr defaultPythonName pythons;

  mkComponent = mkComponentWith base.mkComponent (_: x: x) { };

  mkLibrary = mkComponentWith base.mkLibrary (_: x: x) { setuptoolsLibrary = true; };

  mkClient = mkComponentWith base.mkClient (python: python.pkgs.toPythonApplication) { };

  mkService = mkComponentWith base.mkService (python: python.pkgs.toPythonApplication) { };
}
