# TODO: Add terraform code

locals {
  name = "t-rex"
}

resource "null_resource" "ultra-terraform" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    prehistoric_animal = local.name
  }

  provisioner "local-exec" {
    command = "echo \"${local.name} goes: Roooarrr! 🦖\""
  }
}
