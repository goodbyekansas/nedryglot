{ pkgs, base }:
let
  deployer = pkgs.callPackage ./deployer.nix { };
in
attrs@{ terraformPackage, preDeployPhase ? "", postDeployPhase ? "", shellInputs ? [ ], inputs ? [ ], ... }:
base.deployment.mkDeployment (attrs // {
  name = "deploy-terraform-${terraformPackage.name}";
  deployPhase = ''command ${deployer}/bin/terraform-deploy --source ${terraformPackage}/src "$@"'';
  inherit preDeployPhase postDeployPhase shellInputs inputs;
})
