{ base }:
base.languages.python.mkLibrary {
  name = "shell-setup";
  version = "1.0.0";
  src = ./.;

  # This custom builder is just to make our checks pass for this component, which can't
  # be built until someone enters the shell and does the setup.
  builder = builtins.toFile "shell-thingy" ''
    source $stdenv/setup
    touch $out
  '';
  format = "other";

  shellCommands = {
    # You can add commands to the shell by specifying them like below.
    cleanup = {
      description = "Cleans up the generated folders.";
      script = ''
        echo "🧹 Cleaning up!"
        shopt -s extglob
        rm -rf ..?* .[!.]* !(shell-setup.nix)
        echo "🦕💨 Done!"
      '';
    };
  };
}
