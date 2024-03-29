{ base }:
base.languages.python.mkLibrary {
  name = "numpy-wrapper";
  version = "1.0.0";
  src = ./.;

  # We define this as a function that will be called with the python
  # versions packages, this way we know the packages match the python
  # version provided through base.languages.python. We use
  # propagatedBuildInputs so it becomes available to components
  # depending in this component.
  # [Documentation](https://nixos.org/manual/nixpkgs/stable/#ssec-stdenv-dependencies)
  propagatedBuildInputs = pp: [ pp.numpy ];
}
