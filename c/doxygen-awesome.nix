{ stdenv, fetchFromGitHub }:
stdenv.mkDerivation rec {
  name = "doxygen-awesome-css";
  version = "2.2.0";
  src = fetchFromGitHub {
    owner = "jothepro";
    repo = name;
    rev = "v${version}";
    sha256 = "sha256-hcZiHrlgeBLvEhzJk0iZ2GpSxVPn/mjt2Hkt6Mh00OU=";
  };
  installFlags = [ "PREFIX=$(out)" ];
  postInstall = ''
    echo "GENERATE_TREEVIEW      = YES
    DISABLE_INDEX          = NO
    FULL_SIDEBAR           = NO
    HTML_EXTRA_STYLESHEET  = $out/share/doxygen-awesome-css/doxygen-awesome.css \
                            $out/share/doxygen-awesome-css/doxygen-awesome-sidebar-only.css
    HTML_COLORSTYLE        = LIGHT # required with Doxygen >= 1.9.5 ">"$out/Doxyfile"
  '';
}
