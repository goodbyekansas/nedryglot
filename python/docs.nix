{ base, sphinx, lib }:
let
  docsConfig = lib.filterAttrs (_: v: v != "" && v != [ ]) (base.parseConfig {
    key = "docs";
    structure = {
      python = {
        generator = "sphinx";
        sphinx-theme = "";
        sphinx-extensions = [ ];
      };
      author = "";
      authors = [ ];
      logo = "";
    };
  });

  sphinxTheme = {
    rtd = {
      name = "sphinx_rtd_theme";
      conf = "html_theme = \\\"sphinx_rtd_theme\\\"";
    };
  }."${docsConfig.python.sphinx-theme}" or null;

  componentConfig = lib.filterAttrs (_: v: v != "") (base.parseConfig {
    key = "components";
    structure = { author = ""; };
  });

  author =
    if docsConfig ? authors then
      builtins.concatStringsSep ", " docsConfig.authors
    else docsConfig.author or (componentConfig.author or "Unknown");

  logo =
    if docsConfig ? logo then
      (
        if (builtins.isPath docsConfig.logo && builtins.pathExists docsConfig.logo) then {
          source = docsConfig.logo;
          path = "./${builtins.baseNameOf docsConfig.logo}";
        } else { path = docsConfig.logo; }
      ) else { };
in
{
  __functor = self: self."${docsConfig.python.generator}";

  sphinx = attrs@{ name, src, pythonVersion, ... }: {
    api = base.mkDerivation {
      inherit src;
      doCheck = false;
      name = "${name}-api-reference";
      nedrylandType = "documentation";
      nativeBuildInputs = [ sphinx ]
        ++ lib.optional (sphinxTheme != null) pythonVersion.pkgs."${sphinxTheme.name}"
        ++ attrs.nativeBuildInputs or [ ];
      buildInputs = (attrs.buildInputs or [ ])
        ++ (attrs.propagatedBuildInputs or [ ]);

      srcFilter = path: type: (
        builtins.match ".*\.py" (baseNameOf path) != null
      )
      && baseNameOf path != "setup.py"
      || type == "directory";
      configurePhase = ''
        sphinx-apidoc \
          --full \
          --follow-links \
          --append-syspath \
          -H "${name}" \
          ${lib.optionalString (attrs ? version) "-V ${attrs.version}"} \
          -A "${author}" \
          -o doc-source \
          .

        mkdir -p doc-source
        echo "" >> doc-source/conf.py # generated conf.py does not end in a newline
        sed -i -r 's/(extensions = \[)/\1${builtins.concatStringsSep "," (builtins.map (s: ''"${s}"'') (docsConfig.python.sphinx-extensions ++ [ "sphinx.ext.napoleon" ]))},/g' doc-source/conf.py
        echo "napoleon_include_init_with_doc = True" >> doc-source/conf.py
        ${if attrs ? docsConfig && attrs.docsConfig ? autodocMockImports then "echo 'autodoc_mock_imports = [${builtins.concatStringsSep ", " (builtins.map (v: "\"${v}\"") attrs.docsConfig.autodocMockImports)}]' >> doc-source/conf.py" else ""} 
        ${if sphinxTheme != null then "echo ${sphinxTheme.conf} >> doc-source/conf.py" else "" }
        ${if logo != { } then "echo 'html_logo = \"${logo.source or logo.path}\"' >> doc-source/conf.py" else ""}
      '';
      buildPhase = ''
        cd doc-source
        make html
      '';
      installPhase = ''
        mkdir -p $out/share/doc/${name}/api
        cp -r _build/html/. $out/share/doc/${name}/api
      '';
    };
  };

  pdoc = attrs@{ name, src, pythonVersion, ... }:
    {
      api = base.mkDerivation {
        inherit src;
        doCheck = false;
        name = "${name}-api-reference";
        nedrylandType = "documentation";
        nativeBuildInputs = [ pythonVersion.pkgs.pdoc ] ++ attrs.nativeBuildInputs or [ ];
        buildInputs = attrs.buildInputs or [ ]
          ++ attrs.propagatedBuildInputs or [ ];
        configurePhase = ''
          modules=$(python ${./print-module-names.py})
          ${if logo != { } then "cp -r ${./pdoc-template} ./template" else ""}
          ${if logo != { } then "substituteInPlace ./template/module.html.jinja2 --subst-var-by \"logo\" \"${logo.path}\"" else ""}
          ${if logo != { } then "substituteInPlace ./template/index.html.jinja2 --subst-var-by \"logo\" \"${logo.path}\"" else ""}
        '';
        buildPhase = ''
          pdoc -o docs "$modules" ${if logo != { } then "--template ./template" else ""}
        '';
        installPhase = ''
          mkdir -p $out/share/doc/${name}/api/
          cp -r docs $out/share/doc/${name}/api/
          ${if logo ? source then "cp ${logo.source} $out/share/doc/${name}/api/${logo.path}" else ""}
        '';
      };
    };
}
