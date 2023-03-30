# Overriding platforms
In the c language the notion of a platform is the same as the notion
of a platform in nix with the addition of toolset. In other words
linux+clang and linux+gcc are different platforms.

Platforms in the c language controls which targets components generate
when using the `mk*` functions.

For example if there is a platform definition for `windows` a
component created with for example `mkLibrary` will have a `windows`
target.

## Build Systems
Since C and C++ have many different build systems without any clear
standard, nedryglot makes no assumptions about which one is used.

Adding support for a custom build system would look something like
[the factory example](#factory-example).

## Examples

### Adding a platform definition

```
base.languages.c.overridePlatforms
    (_platforms: {
        # This will be accessible as <component>.riscv
        riscv = base.languages.c.mkPlatform {
            name = "RISC-V";
            pkgs = pkgsCross.riscv64;
            platformOverrides = attrs {
                # This will ensure all derivations created with this platform will
                # have the hello example as dependency.
                buildInputs = attrs.buildInputs or [] ++ [ pkgsCross.riscv64.hello ];
            };
        };

        linux-clang = base.languages.c.mkPlatform {
            name = "Linux-Clang";
            inherit pkgs;
            stdenv = pkgs.clangStdenv;

            # This will be accessible as <component>.clang
            output = "clang";
        };
    })
}
```

### Changing an existing platform definition
Changes the target name by adding the prefix mega.
```
base.languages.c.overridePlatforms
    (builtins.mapAttrs (
        platformName: platform:
        platform.override {
            output = "mega-${platformName}";
        }
    ))
```

### <a name="factory-example"></a> Changing the platforms factory function (`mkDerivation`)
In this example we change the default `doxygenOutputDir`. The
derivation is modified to add the prefix "sune" to all derivation
names, also adds an extra buildInput.

```
base.languages.c.overridePlatforms
    (builtins.mapAttrs (
        _platformName: platform:
        platform.overrideFactory {
            overrideAttrs = attrs: {
                # All derivations will have the name sune
                name = "sune-${attrs.name}";
                buildInputs = [ platform.pkgs.tbb ] ++ attrs.buildInputs or [];
            };
            doxygenOutputDir = "special/docs/folder";
        }
    ))
```

