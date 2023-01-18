terraform:
# Check that the terraform version is as expected
let
  component = terraform.mkComponent { name = "jordklot"; src = null; };
in

assert component.terraform.terraform == terraform.defaultVersion;

pkgs:
# Check that we can override the terraform version
let
  component = (terraform.override { terraform = pkgs.terraform_0_13; }).mkComponent { name = "mars"; src = null; };
in
assert if pkgs.lib.versionOlder pkgs.lib.version "22.11pre-git" then component.terraform.terraform == pkgs.terraform_0_13 else true;

builtins.trace "✔️ Terraform tests succeeded ${terraform.emoji}" { }
