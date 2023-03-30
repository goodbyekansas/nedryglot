# C/C++

## Declaring Components
Components using C or C++ are grouped under `base.languages.c` and use the same toolset.
Use `mkClient`, `mkService` or `mkLibrary` to create components of the
corresponding type. Available tools for the development shell include clangd,
valgrind and doxygen. Doxygen comes wrapped with a theme and some default settings.

## Specifying Dependencies & Cross Compilation
A minimal component setup can look like this:
```nix
{ languages }:
languages.c.mkLibrary {
    name = "example";
    version = "4.4.4";
    src = ./.;
}
```

However, when dependencies are needed it is recommended to define the component
attributes as a function with those dependencies as an input:
```nix
{ languages }:
languages.mkLibrary ({ harfbuzz }: {
    name = "example";
    version = "4.5.3";
    src = ./.;
    buildInputs = [ harfbuzz ];
})
```
When using a function it will be called with packages for the target platform,
making cross compilation work correctly.

When depending on other Nedryland components they will be resolved to the
correct platform as well, but only when used in any of the variations of the
buildInputs attributes.

```nix
{ languages }:
languages.mkLibrary ({ harfbuzz, componentA }: {
    name = "example";
    version = "5.0.0";
    src = ./.;
    buildInputs = [ harfbuzz componentA ];
    randomAttr = [ componentA ];
})
```

In this example componentA will be resolved to the correct platform in
buildInputs, but in randomAttr it will still be the whole component. To manually
resolve a target, the `targetName` string can be depended on:

```nix
{ languages }:
languages.mkLibrary ({ harfbuzz, componentA, targetName }: {
    name = "example";
    version = "5.0.0";
    src = ./.;
    buildInputs = [ harfbuzz componentA ];
    randomAttr = [ componentA.${targetName} ];
})
```

## Documentation

C/C++ components comes with a Doxygen with some defaults (project name and
version set to the component's name and version for example), these defaults can
be overriden by the Doxyfile in the component's directory. To view the resulting
config use `doxygen --print-generated-config`. This doxygen also comes with
[doxygen-awesome-css](https://github.com/jothepro/doxygen-awesome-css) for a
more modern styling.
