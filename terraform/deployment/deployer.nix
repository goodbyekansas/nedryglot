{ python3 }:
python3.pkgs.buildPythonApplication
{
  name = "terraform-deployer";
  version = "2.0.1";
  src = ./.;
}
