{ pkgs, nedryland, ... }:
let
  nedrylandPkgs = (nedryland { inherit pkgs; }).pkgs;
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

    inherit callFunction callFile;
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
            # important to use nedrylandPkgs here since we are emulating what nedryland does.
            (builtins.intersectAttrs args nedrylandPkgs)
            // (builtins.intersectAttrs args (mockBase // { base = mockBase; }))
            // overrides
          )
      );
  inherit ((mockBase.callFile ./languages.nix { }).languages) python terraform rust;
in
rec {

  tests = {
    python = import ./tests/python.nix python nedrylandPkgs;
    terraform = import ./tests/terraform.nix terraform nedrylandPkgs;
    rust = import ./tests/rust.nix rust nedrylandPkgs;
  };

  all = builtins.attrValues tests;
}
