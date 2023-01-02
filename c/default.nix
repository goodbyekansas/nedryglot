{ base, callPackage }:
let
  inherit (callPackage ./common.nix { inherit base; }) mkComponentWith;

  lintPhase = ''
    runHook preLint
    (
    cd ..
    GLOBIGNORE=build/**
    shopt -s nullglob
    echo "💄 Checking formatting on C files..."
    clang-format --style=file -Werror -n **/*.h **/*.c

    if [ $? -eq 0 ]; then
      echo "💄 Perfectly formatted!"
    fi

    if [ -f CMakeLists.txt ]; then
      echo "🦷 Checking formatting on CMakeFiles"
      cmake-format --check **/*.cmake CMakeLists.txt **/CMakeLists.txt
    fi
    )
    runHook postLint
  '';
in
{
  name = "C";
  emoji = "🇨";
  description = ''
    C is a general-purpose computer programming language.
  '';

  mkComponent = args: mkComponentWith "c" base.mkComponent ({ inherit lintPhase; } // args);
  mkClient = args: mkComponentWith "c" base.mkClient ({ inherit lintPhase; } // args);
  mkService = args: mkComponentWith "c" base.mkService ({ inherit lintPhase; } // args);
  mkLibrary = args: mkComponentWith "c" base.mkLibrary ({ inherit lintPhase; } // args);
}
