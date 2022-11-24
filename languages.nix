{ base, callPackage, lib, python3 }:
assert lib.assertMsg (base ? versionAtLeast && base.versionAtLeast "8") "Nedryglot requires at least Nedryland version 8.0.0";
{
  languages = rec{
    rust = callPackage ./rust { inherit base; };
    python = callPackage ./python { python = python3; inherit base; };
    terraform = callPackage ./terraform { inherit base; };
  };
}
