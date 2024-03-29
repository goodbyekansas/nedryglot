{ base, lib, terraform, symlinkJoin }:
let
  terraformPkg = terraform;
  mkDeployment = base.callFile ./deployment { };
  mkComponent =
    attrs'@{ name
    , src
    , buildInputs ? [ ]
    , enableApplyInShell ? false
    , preTerraformHook ? ""
    , postTerraformHook ? ""
    , preDeployPhase ? ""
    , postDeployPhase ? ""
    , deployShellInputs ? [ ]
    , enableTargetSetup ? true
    , ...
    }:
    let
      attrs = builtins.removeAttrs attrs' [ "variables" "srcExclude" "shellCommands" ];
    in
    base.mkComponent rec {
      inherit name;
      _default = terraform;
      terraform = base.mkDerivation (attrs // {
        inherit name src;
        terraform = terraformPkg;
        buildInputs = [ terraformPkg ] ++ buildInputs;

        checkPhase = ''
          terraform init -backend=false
          terraform fmt -recursive -check -diff
          terraform validate
        '';

        installPhase = ''
          runHook preInstall

          mkdir -p $out/src
          cp -r $src/. $out/src/

          runHook postInstall
        '';
        phases = [ "unpackPhase" "installPhase" "checkPhase" ];
        shellCommands = {
          terraform = {
            script = ''
              ${preTerraformHook}
              subcommand="$1"
              ${if !enableApplyInShell then ''
                if [ $# -gt 0 ] && [ "$subcommand" == "apply" ]; then
                  echo "Local 'apply' has been disabled, which probably means that application of Terraform config is done centrally"
                  exit 1
                else
                  ${terraformPkg}/bin/terraform "$@"
                fi
              '' else ''
                ${terraformPkg}/bin/terraform "$@"
              ''}
              ${postTerraformHook}'';
            description = if !enableApplyInShell then "Terraform wrapper with apply disabled." else "Runs terraform.";
          };
        } // attrs'.shellCommands or { };

      } // (lib.optionalAttrs enableTargetSetup {
        targetSetup = base.mkTargetSetup {
          inherit (attrs) name;
          typeName = "terraform";
          markerFiles = attrs.targetSetup.markerFiles or [ ] ++ [ "main.tf" ];

          templateDir = symlinkJoin {
            name = "terraform-component-template";
            paths = (
              lib.optional (attrs ? targetSetup.templateDir) attrs.targetSetup.templateDir
            ) ++ [ ./component-template ];
          };
        };
      }));

      deployment = {
        terraform = lib.makeOverridable mkDeployment (attrs // {
          terraformPackage = terraform;
          inherit preDeployPhase postDeployPhase;
          shellInputs = deployShellInputs;
          inputs = terraform.buildInputs;
        });
      };
    };
in
{
  name = "terraform";
  emoji = "🌍";
  description = ''
    Terraform is an infrastructure as code tool that lets you build,
    change, and version cloud and on-prem resources safely and
    efficiently.
  '';

  mkTerraformComponent = attrs: builtins.trace "Warning: ${attrs.src}: base.languages.terraform.mkTerraformComponent is deprecated. Use base.languages.terraform.mkComponent instead" mkComponent attrs;
  defaultVersion = terraformPkg;
  inherit mkDeployment mkComponent;
}
