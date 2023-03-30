nedryland:
let
  pkgs = nedryland.pkgs;
  mockBase = rec {
    versionAtLeast = _: true;
    mkComponent = attrs: attrs // { isNedrylandComponent = true; };
    mkLibrary = mkComponent;
    mkClient = mkComponent;
    mkService = mkComponent;
    mkTargetSetup = mkComponent;
    parseConfig = { structure, ... }: structure;
    mkDerivation = attrs:
      let
        inner = attrs: attrs // { isNedrylandDerivation = true; type = "derivation"; };
        drv = (pkgs.lib.makeOverridable inner attrs);
      in
      drv // {
        overrideAttrs = f: drv // (f drv);
      };

    resolveInputs = name: typeName: targets: builtins.map
      (input:
        if input ? isNedrylandComponent then
          builtins.getAttr
            (pkgs.lib.findFirst
              (target: builtins.hasAttr target input)
              (abort "${name}.${typeName} has none of the targets ${builtins.toString targets}.")
              targets)
            input
        else
          input
      );
    components = {
      servisen = c.mkService { name = "plate"; version = "1.2.1"; src = null; };
    };
    inherit callFunction callFile;

    mapComponentsRecursive = _f: _a: { };
  };

  # callFile and callFunction will auto-populate dependencies
  # on nixpkgs, base members and project components
  callFile = path: callFunction (import path) path;
  callFunction = function:
    let
      args = builtins.functionArgs function;
    in
    _:
    pkgs.lib.makeOverridable
      (
        overrides:
        function
          (
            (builtins.intersectAttrs args pkgs)
            // (builtins.intersectAttrs args (mockBase // { base = mockBase; }))
            // overrides
          )
      );
  inherit ((mockBase.callFile ./languages.nix { }).languages) python terraform rust c;

  systemEmojis = {
    "aarch64-linux" = "🦾 🐧";
    "aarch64-darwin" = "🦾 🍏";
    "x86_64-darwin" = "x🎱🕕 🍏";
    "x86_64-linux" = "x🎱🕕 🐧";
  };
in
builtins.trace "Running tests for ${pkgs.lib.version} ${pkgs.system} ${systemEmojis.${pkgs.system} or "🖥"}" rec {

  tests = {
    python = import ./tests/python.nix python pkgs;
    terraform = import ./tests/terraform.nix terraform pkgs;
    rust = import ./tests/rust.nix rust pkgs;
    c = import ./tests/c.nix c pkgs;
  };

  all = builtins.attrValues tests;
}
