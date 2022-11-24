# Terraform

Support for building and deploying terraform projects.


## Tests
During `checkPhase` `terraform fmt` and `terraform validate` will be
run.


## Shell commands
Provides a terraform command that runs terraform which can optionally
disable apply in case deployment is done in CI. The default is to
disable `apply` in the shell. If you want apply enabled pass
`enableApplyInShell = true` when creating your component.terraform.tfstate


## Deployment
Deployment uses a custom script that wraps terraform apply and
plan. Additionally you can give the script a path to the terraform
sources, however everything will be set up automatically for you on
the target `deployment.terraform`.

This means you can give the generated deploy script arguments such as
`plan` or `apply`.


## Overriding the terraform version
By default it will use the terraform package from whatever `nixpkgs`
version you are using.

```nix
nedryland.mkProject
{
  baseExtensions = [
    # Nedryglot itself needs to be imported first to have something to override.
    nedryglot 
    # Then we define our override.
    ({ base, pkgs }: {
      languages.terraform = base.languages.terraform.override {
        terraform = pkgs.terraform_0_13;
      };
    })
  ];
}
```

