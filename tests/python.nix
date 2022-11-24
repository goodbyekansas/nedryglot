python:
# Default python version is python3 from nixpkgs and pythonVersion is set
let
  client = python.mkClient { name = "python-version-default"; version = "mega"; src = null; };
in
assert client ? python;
assert client.python ? pythonVersion;

pkgs:
assert client.python.pythonVersion == pkgs.python3;

# Ensure we get docs
assert client ? docs;
assert client.docs ? api;

# Test dependency on other component
let
  dependency = python.mkClient {
    name = "python-dependency";
    version = "sune";
    src = null;
    buildInputs = [ client ];
  };
in
assert dependency.python.pythonVersion == (builtins.head dependency.python.buildInputs).pythonVersion;

# Client with python overridden, should have corresponding pythonVersion in the output
let
  clientOverriddenVersion = (python.override {
    python = pkgs.python;
  }).mkClient {
    name = "python-version-default";
    version = "ultra";
    src = null;
  };
in
assert clientOverriddenVersion.python.pythonVersion == pkgs.python;

# Multiple python version and dependencies accesses the correct python
let
  pythonLang = (python.override {
    python = pkgs.python310;
    pythonVersions = {
      # Note that it is not required to include python310 in the set
      # since it is the default. You can include it in case you want
      # to have a python310 target but it will be the same as the
      # `python` target.
      inherit (pkgs) python38 python311;
    };
  });

  lib = pythonLang.mkLibrary {
    name = "bibblan";
    version = "yes";
    src = null;
  };

  clientWithNixpkgDep = pythonLang.mkClient {
    name = "pythons-with-nixpkg-dep";
    version = "none";
    src = null;
    propagatedBuildInputs = (p: [ p.requests lib ]);
  };

  checker = pythonVersion: target:
    let
      pythonDeps = builtins.filter (builtins.hasAttr "pythonModule") target.propagatedBuildInputs;
    in
    builtins.length pythonDeps == 2 && builtins.all (py: py.pythonModule == pythonVersion) pythonDeps;
in
assert checker pkgs.python310 clientWithNixpkgDep.python;
assert checker pkgs.python311 clientWithNixpkgDep.python311;
assert checker pkgs.python38 clientWithNixpkgDep.python38;

# Ensure that we get wheel for setuptools projects but not for custom ones
let
  client = python.mkClient {
    name = "sir-väs";
    version = "2.0.0";
    src = null;
  };

  clientWithoutWheel = python.mkClient {
    name = "sir-väs";
    version = "2.0.0";
    src = null;
    format = "other";
  };
in
assert builtins.length client.python.outputs == 2;
assert client.python ? wheel;

assert builtins.length clientWithoutWheel.python.outputs == 1;
assert !(clientWithoutWheel.python ? wheel);

builtins.trace "✔️ Python tests succeeded ${python.emoji}" { }
