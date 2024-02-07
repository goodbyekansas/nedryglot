# Overriding Python Version

By default python components in Nedryglot have the target `python`,
this corresponds to the default python version (defaults to python3 in
the package set). Nedryglot can also build multiple versions on the
same component, and when depending on components it selects the target
of the same python version as itself. To override the python version
use `base.languages.python.override` with an attribute set containing
`python` (the default) and any other python versions in
`pythonVersions`. These python versions are assumed to look like
`pythonXX` in nixpkgs.

```nix
nedryland.mkProject
{
  baseExtensions = [
    # Nedryglot itself needs to be imported first to have something to override.
    nedryglot 
    # Then we define our override.
    ({ base, pkgs }: {
      languages.python = base.languages.python.override {
        # Set the default python version.
        python = pkgs.python38;

        pythonVersions = {
          # Add python38, python39 and python310 targets
          inherit (pkgs) python38 python39 python310;
        };
      };
    })
  ];
}
```


# Changing the default checkphase

```nix
base.languages.python.override {
    # Change the default tests and formatter to use ruff
    defaultCheckPhase = "ruffStandardTests";
};
```

The above example changes the default tests and formatter to use ruff.
