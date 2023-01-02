{ base, callPackage, cppcheck }:
let
  inherit (callPackage ./common.nix { inherit base; }) mkComponentWith resolveInputs;

  plusPlus = args: args // {
    lintPhase = args.lintPhase or ''
      runHook preLint
      (
      cd ..
      GLOBIGNORE=build/**
      shopt -s nullglob
      echo "💄 Checking formatting on C++ files..."
      clang-format --style=file -Werror -n **/*.{h,hpp,hh} **/*.{cpp,cxx,cc}

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

    shellInputs = resolveInputs (args.shellInputs or [ ]) ++ [ cppcheck ];
  };
in
{
  name = "C++";
  emoji = "➕";
  description = ''
    C++ is a high-level general-purpose programming language created by Danish computer scientist Bjarne Stroustrup
    as an extension of the C programming language, or "C with Classes".
  '';

  mkComponent = args: mkComponentWith "cpp" base.mkComponent (plusPlus args);
  mkClient = args: mkComponentWith "cpp" base.mkClient (plusPlus args);
  mkService = args: mkComponentWith "cpp" base.mkService (plusPlus args);
  mkLibrary = args: mkComponentWith "cpp" base.mkLibrary (plusPlus args);
}
