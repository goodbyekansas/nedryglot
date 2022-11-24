{ base, numpyWrapper }:
# extension arguments are intersected with components and pkgs
# so any input matching the name of a package will be auto populated
{
  languages = {
    python = {
      mkNumpyPython = attrs@{ name, version, src }:
        base.languages.python.mkClient {
          inherit name version src;
          # Combine inputs with this neat function.
          propagatedBuildInputs = base.languages.python.combineInputs [ numpyWrapper ] attrs.propagatedBuildInputs or [ ];
          shellHook = ''
            echo "This component was made through the extension!"
          '';
        };
    };
  };
}
