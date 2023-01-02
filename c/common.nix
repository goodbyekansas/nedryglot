{ clangd, clang-format, cmake, doxygen, gdb, lib }:
{
  resolveInputs = name: inputType: searchFor: inputs:
    base.resolveInputs name inputType searchFor (
      if builtins.isFunction inputs then
        inputs pkgs
      else
        inputs
    );

  mkComponentWith = lang: wrapper: args@{ name, version, src }: wrapper {
    ${lang} =  base.mkDerivation (
      (builtins.removeAttrs args [ "docs" ]) //
      {
        nativeBuildInputs = resolveInputs name "nativeBuildInputs" [ componentTargetName lang ] attrs.nativeBuildInputs or [ ]
        ++ [ clangd ]
        ++ lib.optional (builtins.pathExists ./. + "/CMakeLists.txt") cmake
        ++ lib.optional (builtins.pathExists ./. + "/Doxyfile") doxygen;
        buildInputs = resolveInputs name "buildInputs" [ componentTargetName lang ] attrs.buildInputs or [ ];
        propagatedBuildInputs = resolveInputs name "propagatedBuildInputs" [ componentTargetName lang ] attrs.propagatedBuildInputs or [ ];
        shellInputs = resolveInputs name "shellInputs" [ componentTargetName lang ] attrs.shellInputs or [ ] ++ [ gdb clangd ];
        checkInputs = resolveInputs name "checkInputs" [ componentTargetName lang ] attrs.checkInputs or [ ] ++ [ clang-format ];

        checkPhase = ''
          runHook preCheck
          make test
          runHook postCheck
        '';

        shellHook = ''
          if [ -f CMakeLists.txt ]; then
            export cmakeFlags="-DCMAKE_EXPORT_COMPILE_COMMANDS=ON $cmakeFlags"
          fi

          ${args.shellHook or ""}
        '';

        shellCommands = {
          format = {
            script = ''
              clang-format -i **/*.h **/*.c
              if [ -f CMakeLists.txt ]; then
                cmake-format --in-place **/*.cmake CMakeLists.txt **/CMakeLists.txt
              fi  
            '';
            description = "Format the code.";
          };
          debug = {
            script = ''dbg "$@"'';
            description = "Run a command with RUST_DEBUG set.";
            args = "command args ...";
          };
          check = {
            script = ''
              NIX_LOG_FD=/dev/null
              phases="checkPhase lintPhase"
              if [ -n "''${crossCheckPhase:-}" ]; then
                phases+=" crossCheckPhase"
              fi
              genericBuild
            '';
            description = "Runs cargo check, clippy and fmt.";
          };
        } // safeAttrs.shellCommands or { };
      });

      docs = lib.optionalAttrs (builtins.pathExists ./. + "/Doxyfile") {
        api = base.mkDerivation {
          inherit version src;
          name = "${name}-api-reference";

          nativeBuildInputs = [
            doxygen
          ];

          buildPhase = ''
            doxygen Doxyfile
          '';

          installPhase = ''
            mkdir -p $out/share/doc/${name}/api
            cp -r doc/html/. $out/share/doc/${name}/api
          '';
        };
      } // args.docs or { };
    };
}
