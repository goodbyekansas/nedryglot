# Introduction

![JP](./assets/nedryglot.png)
Image "from" Jurassic Park © Universal

## What is this?

Nedryglot contains a set of [Nedryland](https://goodbyekansas.github.io/nedryland/) base
extensions with opinionated defaults for a set of programming languages. One core
principle however, is that Nedryglot is only additive, i.e. the source package is also
usable without any involvement of Nedryglot.

Currently supported languages are [Python](./python/components.md),
[Rust](./rust/components.md) and [Terraform](./terraform/components.md).

## How to use it?

Nedryglot comes in form of two base extensions. One for all supported
languages and one for enabling protobuf support for all languages. To
use in your nedryland project, first obtain the sources (using Niv,
`fetchTarball` etc.) and then either include the base extension by
path in the `baseExtensions` argument to `mkProject`:

```nix
mkProject {
  # ...

  baseExtensions = [
    (nedryglotPath + ./languages.nix)
    # other extensions...
    (nedryglotPath + ./protobuf.nix)
  ];
}
```

Alternatively, you can import Nedryglot first, and then include it in
`baseExtensions`.

```nix
let
  nedryglot = import ./path/to/nedryglot/ { };
in
mkProject {
  # ...

  baseExtensions = [
    nedryglot.languages
    # other extensions...
    nedryglot.protobuf
  ];
}
```

After doing this, `base.languages` will contain attributes for the
supported languages. Note that protobuf support is optional and to
disable it you can simply omit it from `baseExtensions`. If you want
protobuf it should be placed after all extension that defines
languages.

All languages comes with functions to create components for specific purposes,
such as mkLibrary or mkService. These functions takes an attribute set as
argument and creates a target on the component for that purpose, the default
target for each language is the name of the language. Attributes will appear on that
target, to add attributes to the resulting component, use `overrideAttrs`.

```nix
{ base }:
(base.languages.rust.mkLibrary {
  name = "example";
  src = ./.;
  randomNumber = 4;
}).overrideAttrs (_: {
  anotherNumbers = "three";
})
```

```
$nix eval -f default.nix example.rust.randomNumber --raw
>4
$nix eval -f default.nix example.anotherNumber --raw
>three
```
