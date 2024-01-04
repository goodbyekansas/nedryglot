{ nedryland, oxalica, nedryglot, pkgs }:
let
  nedry = nedryland { inherit pkgs; };
in
nedry.mkProject
{
  name = "the-overrider";

  components = { callFile }: {
    # rosteri and ormgrop will use the overrides from overrides.nix
    rosteri = callFile ./clients/rust/rust.nix { };
    ormgrop = callFile ./clients/python/python.nix { };

    # nattrosteri will use it's own override for rust which only
    # applies to this specific component.
    nattrosteri = callFile ./clients/rust-nightly/rust-nightly.nix { };
  };

  baseExtensions =
    let
      glot = nedryglot;
    in
    [
      glot.languages
      # This is where we set the new default versions for rust and
      # python in glot.languages.
      (import ./extensions/overrides.nix oxalica)
    ];

}
