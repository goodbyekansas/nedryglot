{ name
, extraCargoConfig
, stdenv
, makeSetupHook
, buildInputs
, propagatedBuildInputs
}:
# derivation that creates a fake vendor dir with our internal nix dependencies
stdenv.mkDerivation {
  inherit extraCargoConfig buildInputs propagatedBuildInputs;
  name = "${name}-internal-deps";

  phases = [ "buildPhase" "installPhase" ];
  nativeBuildInputs = [
    (makeSetupHook
      { name = "internal-deps-hook"; }
      ./internalDepsSetupHook.sh)
  ];

  buildPhase = ''
    mkdir -p vendored
    if [ -n "''${rustDependencies}" ]; then
      echo "🏡 vendoring internal dependencies..."

      # symlink in all deps
      for dep in $rustDependencies; do
        ln -sf "$dep" ./vendored/
      done

      echo "🏡 internal dependencies vendored!"
    fi
  '';

  installPhase = ''
    mkdir $out
    cp -r vendored $out
    substitute ${./cargo-internal.config.toml} $out/cargo.config.toml \
      --subst-var-by vendorDir $out/vendored
    echo "$extraCargoConfig" >> $out/cargo.config.toml
    mkdir -p "$out/nix-support"
    substituteAll "$setupHook" "$out/nix-support/setup-hook"
  '';

  setupHook = ./setupHook.sh;
}
