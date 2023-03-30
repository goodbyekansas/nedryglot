let self =
  args@{ base
  , lib
  , pkgs
  , platforms ? { }
  , extraAttrs ? { }
  , generateDocs ? true
  , components
  , mathjax ? null
  }:
  let
    mathjaxDefaultVersion = "3.2.2";
    mathjax' =
      if mathjax == null then
        builtins.fetchurl
          {
            url = "https://cdn.jsdelivr.net/npm/mathjax@${mathjaxDefaultVersion}/es5/tex-svg.js";
            sha256 = "sha256:10m80cpdhk1jqvqvkzy8qls7nmsra77fx7rrq4snk0s46z1msafl";
          } else mathjax;

    inner =
      { name
      , pkgs
      , stdenv ? pkgs.stdenv
      , output ? null
      , platformOverrides ? _: { }
      }:
      let
        factory = pkgs.callPackage (import ./make-derivation.nix platformOverrides)
          {
            inherit base stdenv components;
            targetName = name;
            mathjax = mathjax';
          };

        finalPlatform = factory:
          {
            inherit name pkgs;
            __functor = _self: factory;
            overrideFactory = overrides:
              finalPlatform (
                factory.override overrides);
          } // lib.optionalAttrs (output != null) { inherit output; };
      in
      (finalPlatform factory);

    mkPlatform = lib.makeOverridable inner;

    platforms' = {
      _default = mkPlatform {
        inherit pkgs;
        name = "_default";
      };
    } // platforms;

    createPlatformTargets = attrsOrFn:
      lib.mapAttrs'
        (name: platform: {
          name = platform.output or name;
          value = platform attrsOrFn;
        })
        platforms';

    toComponent = componentFactory: targets:
      componentFactory
        ({
          name = targets._default.name;
          version = targets._default.version;
        } // targets // lib.optionalAttrs generateDocs {
          docs.api = targets._default.doc;
        });
  in
  extraAttrs // rec {
    inherit mkPlatform;
    platforms = platforms' // {
      override = overridePlatforms;
    };

    name = "c/c++";
    emoji = "🦕";
    description = ''
      C/C++
    '';

    overrideAttrs = f: self (args // {
      extraAttrs = (extraAttrs // (f extraAttrs));
    });
    overridePlatforms = f: self (args // {
      platforms = (platforms' // (f platforms'));
    });
  } // (
    builtins.listToAttrs
      (builtins.map
        (t: { name = "mk${t}"; value = attrsOrFn: toComponent base."mk${t}" (createPlatformTargets attrsOrFn); })
        [ "Library" "Client" "Service" ]));
in self
