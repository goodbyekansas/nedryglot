platformOverrides:
{ base
, stdenv
, pkgs
, lib
, buildPackages
, substitute
, writeShellScriptBin
, components
, targetName
, doxygenOutputDir ? "doc"
, mathjax
, enableDoxygen ? true
, doxygenTheme ? null
, overrideAttrs ? _: { }
}:

attrsOrFn:

let
  doxygenTheme' =
    if doxygenTheme == null then
      buildPackages.callPackage ./doxygen-awesome.nix { }
    else doxygenTheme;

  doxyfile = attrs: substitute {
    name = "Doxyfile";
    src = ./Doxyfile;
    replacements = [
      "--subst-var-by"
      "name"
      attrs.name
      "--subst-var-by"
      "version"
      attrs.version
      "--subst-var-by"
      "outputDirectory"
      attrs.doxygenOutputDir or doxygenOutputDir
    ];
  };


  wrappedDoxygen = outputDir: doxyfiles: writeShellScriptBin "doxygen" ''
    set -euo pipefail
    doxyfiles=(${builtins.concatStringsSep " " doxyfiles})
    : ''${componentDir=$PWD}
    if [ -e "$componentDir/Doxyfile" ]; then
      doxyfiles+=("$componentDir/Doxyfile")
    fi
    if [[ $@ =~ "--print-generated-config" ]]; then
      ${buildPackages.bat}/bin/bat "''${doxyfiles[@]}"
      exit 0
    fi

    # copy mathjax
    mkdir -p "${outputDir}"/html/mathjax/
    cp --no-preserve=mode "${mathjax}" "${outputDir}"/html/mathjax/MathJax.js

    if [ $# -eq 0 ]; then
      ${buildPackages.doxygen}/bin/doxygen <(cat "''${doxyfiles[@]}")
    else
      ${buildPackages.doxygen}/bin/doxygen "$@"
    fi
  '';

  attrsOrFn' =
    if builtins.isPath attrsOrFn then
      import attrsOrFn
    else
      attrsOrFn;

  attrsFn =
    if builtins.isFunction attrsOrFn' then
      attrsOrFn'
    else
      _: attrsOrFn';

  fn = args:
    let
      attrs = attrsFn args;
      mkDerivationArgs = {
        inherit stdenv;
        doCheck = true;
        strictDeps = true;
        outputs = [ "out" ] ++ lib.optionals (attrs.enableDoxygen or enableDoxygen) [ "doc" "man" ];
      } // attrs // {
        nativeBuildInputs = [
          buildPackages.clang-tools
          buildPackages.valgrind
        ]
        ++ attrs.nativeBuildInputs or [ ]
        ++ lib.optional (attrs.enableDoxygen or enableDoxygen) (
          wrappedDoxygen
            (attrs.doxygenOutputDir or doxygenOutputDir)
            [
              (doxyfile attrs)
              "${doxygenTheme'}/Doxyfile"
            ]
        );

        shellInputs = [
          pkgs.${attrs.debugger or "gdb"}
        ] ++ attrs.shellInputs or [ ];

        lintPhase = attrs.lintPhase or ''
          runHook preLint
          if [ -z "''${dontCheckClangFormat:-}" ]; then
            echo "🏟 Checking format in C/C++ files..."
            ${buildPackages.fd}/bin/fd --ignore-file=.gitignore --glob '*.[h,hpp,hh,cpp,cxx,cc,c]' --exec-batch clang-format -Werror -n --style=LLVM
            rc=$?

            if [ $rc -eq 0 ]; then
              echo "✅ perfectly formatted!"
            fi
          fi
          runHook postLint
        '';

        shellCommands = {
          build = {
            script = ''
              : ''${NIX_LOG_FD:=} ''${buildFlags:=}
              phases="''${preConfigurePhases:-} configurePhase ''${preBuildPhases:-} buildPhase"
              genericBuild
            '';
            description = "Build the component.";
          };
          format = {
            script = ''
              runHook preFormat
              echo "🏟️ Formatting C++ files..."
              ${buildPackages.fd}/bin/fd --glob '*.[h,hpp,hh,cpp,cxx,cc,c]' --exec-batch clang-format --style=LLVM -i "$@"
              runHook postFormat
            '';
            description = "Format source code in the component.";
          };
          check = {
            script = ''
              : ''${NIX_LOG_FD:=} ''${buildFlags:=} ''${lintPhase:=echo 'no lintPhase'}
              phases="''${preConfigurePhases:-} configurePhase ''${preBuildPhases:-} buildPhase checkPhase lintPhase"
              genericBuild
            '';
            description = "Run the checks and lints for the component.";
          };
          debug = {
            script = ''${attrs.debugger or "gdb"} ${if attrs ? executable then "${attrs.executable} \"$@\"" else "$@"}'';
            description = "Run ${attrs.debugger or "gdb"}${if attrs ? executable then " on ${attrs.executable}" else ""}.";
          };
        }
        // lib.optionalAttrs (attrs ? executable) {
          run = {
            script = ''./${attrs.executable} "$@"'';
            description = "Run ${attrs.executable}";
          };
        } // lib.optionalAttrs enableDoxygen {
          show-doxyfile = {
            script = "doxygen --print-generated-config";
            description = "Show the combination of Doxygen files that will be used by Doxygen.";
          };
          docs = {
            script = ''
              doxygen && xdg-open ${attrs.doxygenOutputDir or doxygenOutputDir}/html/index.html
            '';
            description = "Show the documentation.";
          };
        }
        // attrs.shellCommands or { };
      };

      platformAttrs = mkDerivationArgs // (platformOverrides mkDerivationArgs);
      attrs' = platformAttrs // (overrideAttrs platformAttrs);

    in
    base.mkDerivation attrs';

  splicedComponents = base.mapComponentsRecursive
    (_path: component:
      if builtins.hasAttr targetName component then
      # Promote the requested target to top-level on the component. This makes it
      # possible to still use other targets on the components if needed. I.e. <component>
      # will be the requested target whereas <component>.<other-target> will be the other
      # target.
        component.componentAttrs // component."${targetName}"
      else
        component
    )
    components;
in
lib.makeOverridable fn (
  builtins.intersectAttrs
    (builtins.functionArgs attrsFn)
    (pkgs // splicedComponents // { inherit stdenv; })
)
