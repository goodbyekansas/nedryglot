{ pkgs }:
pkgs.stdenv.mkDerivation rec {
  name = "nedryglot-docs";
  src = builtins.path { inherit name; path = ./docs; };
  changelog = ./CHANGELOG.md;
  postUnpack = "cp $changelog CHANGELOG.md";
  buildInputs = [ pkgs.mdbook ];
  buildPhase = "mdbook build --dest-dir book";
  installPhase = ''
    mkdir -p $out/share/doc/nedryglot/manual
    cp -r book/. $out/share/doc/nedryglot/manual
  '';
  shellHook = ''
    cd docs
  '';
}
