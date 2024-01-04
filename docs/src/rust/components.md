# Rust components


## mkLibrary mkService mkClient mkComponent

- `mkService` and `mkClient` builds binaries.
- `mkLibrary` creates an unpacked rust package (unpacked .crate file) since rust
  builds everything from source, which can be depended on by other components.
- `mkComponent` is made for building extensions where you can create your own
  Nedryland component types by passing in the `nedrylandType` string.

## Specifying Crate Dependencies

In order to be deterministic crates are downloaded and verified ahead of building, and
these crates need to be made available to the build environment. This is done through
`buildInputs` and `propagatedBuildInputs`. Crates can be be defined using
`base.languages.rust.fetchCrate {name = "some-crate-name"; version = "x.y.z"; sha256 = "sha"; deps = [crate]}`
where sha256 is the same as you will find on
[crates index](https://github.com/rust-lang/crates.io-index) and deps is a list of these
kind of derivations.

To ease writing of multiple such expressions there's a CLI tool
`gen-crate-expression` both in each rust shell and as an app in Nedryglot's
flake. Use `gen-crate-expression --help` for usage information.

A set of crates has also been generated and ships with nedryglot under
`base.languages.rust.crates`. These are roughly equivalent to the crates available in
[Rust Playground](https://play.rust-lang.org/) (that is, the 100 most downloaded crates on
[crates.io](https://crates.io/crates?sort=downloads)). This default crate set can be
overridden by making an extension. This extension overrides the crate set with a set of
one crate:

```nix
{ base }:
{
  languages.rust = base.languages.rust.overrideAttr {
    crates = {
      gimli = base.languages.rust.fetchCrate {
        name="gimli";
        version="0.27.3";
        sha256="b6c80984affa11d98d1b88b66ac8853f143217b399d3c74116778ff8fdb4ed2e"; deps=[];
      };
    };
  };
}
```

## Specifying Other Dependencies

Specifying dependencies in a Rust component can be done in two ways. First option is to
assign any of the standard `mkDerivation` arguments a list with the needed inputs.

```nix
# in the component nix file
{ base, lib, hello }:
base.languages.rust.mkClient {
  name = "krabba";
  src = ./.;

  # always depend on hello from the build platform
  buildInputs = [ hello ]
}
```

In the above example, note that we are always depending on the `hello` package from the
build platform (see [below](#about-platforms)). If we are not cross-compiling, this is
fine.

To ease cross compilation, a concept called `splicing` is used and to take
advantage of that, the same arguments can also be assigned a function with a single
argument `pkgs`. This function must return a list with the desired dependencies. `pkgs`
will be the correct package set for the current platform, making it possible to use the
same dependency specification for multiple platforms.

```nix
# in the component nix file
{ base, lib }:
base.languages.rust.mkClient {
  name = "krabba";
  src = ./.;
  buildInputs = pkgs: 
    # depend on hello for all platforms
    [ pkgs.hello ]

    # depend on pthreads only for windows
    ++ lib.optional (pkgs.stdenv.hostPlatform.isWindows) pkgs.windows.pthreads

    # and something only for wasi
    ++ lib.optional (pkgs.stdenv.hostPlatform.isWasi) pkgs.someWasiDependency
}
```


## Cross Compilation

Nedryglot supports adding cross build targets to the rust language in addition
to the provided default target. The default target is always called `rust`
irrespective of platform. To add more targets either override `base.languages.rust`
and send in more `crossTargets`, which by default is an empty set.


### About Platforms

The platform concept is borrowed from tools like GNU autotools and might require some
explanation since it is central to cross-compilation and not entirely intuitive.

#### Build Platform
This is the platform we are currently building on.

#### Host Platform
This is the platform we are building _for_. I.e. the platform that the software will run
on. If we are not cross compiling, build platform and host platform are always the same.

#### Target Platform
This only makes sense if the software is compiler-like. For example, a compiler built on
Linux for Linux will have Linux as build platform and host platform. However, even though
it runs on Linux, it might produce binaries for Windows. I.e. Windows is the target platform.


### mkCrossTarget

Nedryglot exposes `mkCrossTarget` through `base.languages.rust.mkCrossTarget`. This
function allows you to create your own custom cross target with the correct
arguments. It furthermore allows adding attributes to all targets using that target
definition.

```nix
# ...
myCrossTarget = base.languages.rust.mkCrossTarget {
  name = "🐟-Ƽ";
  pkgs = pkgsCross.fiscFive;
  
  # attrs requires a function with one argument,
  # containing the attributes from the package using
  # the cross target
  attrs = pkgAttrs: {

    # the target requires the special
    # build input "blubb" to produce
    # valid builds
    buildInputs = 
      base.languages.rust.combineInputs
      (pkgAttrs.buildInputs or [ ])
      (pkgs: [ pkgs.blubb ])
  };
};
```

Note also the use of `combineInputs` to combine input declarations, irrespective of if
they are functions or lists.


To add cross targets per component:
```nix
# in the component nix file.
{ base, pkgsCross }:
(base.languages.rust.override {
  crossTargets = {
    windows = base.languages.rust.mkCrossTarget {
      name = "Windows";
      pkgs = pkgsCross.mingwW64;
    };
  };
}).mkClient {
  ...
}
```

To add a cross target for every rust component in the project
```nix
# project.nix
nedryland.mkProject {
  name = "windows-target-example";
  baseExtensions = [ ./rust-target-extension.nix ];
}

```

The cross targets are exposed as `<component>.<target>` which would in the above example
be `<component>.windows`. As stated above, the default target is always called `rust`.

```nix
# rust-target-extension.nix
{ base, pkgsCross }:
{
  languages.rust = base.languages.rust.override {
    crossTargets = {
      windows = base.languages.rust.mkCrossTarget {
        name = "Windows";
        pkgs = pkgsCross.mingwW64;
      };
    };
  };
}
```

In the above example, the project-wide meaning of `base.languages.rust` is changed to
include cross-builds for Windows. However, it is also possible to create different
variations of the language by assigning to a different attribute,
e.g. `base.languages.rustWithWindows`.

When a cross compilation target has been added project-wide, it is still possible to opt
out of using it by overriding locally in a component. For example, to only build for the
build platform:

```nix
# in the component nix file
{ base }:
(base.languages.rust.override {
  crossTargets = { };
}).mkClient {
  ...
}
```

This will cause the above added `windows` target to be removed and this component will
only build for the build platform, accessible on the component target `rust`.

### Overriding the Default Target

A component might only make sense to build for a cross target. To change the meaning of
the default target (`rust`), override the attribute `rust` in the cross target set, like
this:

```nix
# in the component nix file
{ base }:
(base.languages.rust.override {
  crossTargets = {
    rust = base.languages.rust.mkCrossTarget {
    name = "Windows";
    pkgs = pkgsCross.mingwW64;
  };
}).mkClient {
  ...
}
```

This will cause `rust` to correspond to a Windows build of the component. It is also
possible to refer to an existing cross target through `crossTargets`

```nix
# in the component nix file
{ base }:
(base.languages.rust.override {
  crossTargets = {
    rust = base.languages.rust.crossTargets.windows;
}).mkClient {
  ...
}
```

This will yield the same result as the previous example if `windows` is already a defined target.

### Adding Cross Targets

Using `override` on the rust language means that any cross target definitions sent in will
replace the existing ones (with the exception of `rust` which is added if it does not
exist in `crossTargets`). To add a new cross target without replacing the existing ones,
use `overrideCrossTargets`:

```nix
# rust-target-extension.nix
{ base, pkgsCross }:
{
  languages.rust = base.languages.rust.overrideCrossTargets (prevTargets: {
    windows = base.languages.rust.mkCrossTarget {
      name = "Windows";
      pkgs = pkgsCross.mingwW64;
    };
  });
}
```

This will add the `windows` target without removing any of the pre-existing targets. Note
that `overrideCrossTargets` also expects a function for the first argument, which gives
access to the set of `crossTargets` that existed before the call to
`overrideCrossTargets`. This makes it easier to create new targets based on existing ones.

