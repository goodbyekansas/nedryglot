{ base, callPackage, lib, python3, components }:
assert lib.assertMsg (base ? versionAtLeast && base.versionAtLeast "9") "Nedryglot requires at least Nedryland version 9.0.0";
{
  languages = rec{
    rust = callPackage ./rust { inherit base; };
    python = callPackage ./python { python = python3; inherit base; };
    terraform = callPackage ./terraform { inherit base; };
    c = callPackage ./c {
      inherit base components;
      # platforms is an attribute in nixpkgs
      platforms = { };
    };
  };
}
