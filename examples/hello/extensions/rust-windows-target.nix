{ base, pkgsCross, callPackage }:
{
  # Defining our own windows rust taget.
  languages.rust = base.languages.rust.crossTargets.override (_previousCrossTargets: {
    windows = base.languages.rust.mkCrossTarget {
      name = "Windows";
      pkgs = pkgsCross.mingwW64;
      attrs = pkgAttrs:
        rec {
          doCrossCheck = true;
          runner = callPackage ./windows-runner.nix { };

          nativeBuildInputs = base.languages.rust.combineInputs
            pkgAttrs.nativeBuildInputs or [ ]
            [ runner ];

          buildInputs = base.languages.rust.combineInputs
            pkgAttrs.buildInputs or [ ]
            (pkgs: [ pkgs.windows.pthreads ]);
        };
    };
  });
}
