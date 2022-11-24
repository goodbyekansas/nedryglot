# Nedryglot

[![Checks](https://github.com/goodbyekansas/nedryglot/actions/workflows/ci.yaml/badge.svg)](https://github.com/goodbyekansas/nedryglot/actions/workflows/ci.yaml)
[![Deploy Github Pages](https://github.com/goodbyekansas/nedryglot/actions/workflows/deploy-book.yml/badge.svg)](https://github.com/goodbyekansas/nedryglot/actions/workflows/deploy-book.yml)

[Nedryland](https://github.com/goodbyekansas/nedryland) extension with language tooling and opinionated defaults.

# Using Nedryglot with Nedryland
Nedryglot comes in form of two base extensions. One for all supported
languages and one for enabling protobuf support for all languages. To
use in your nedryland project, first obtain the sources (using Niv,
`fetchTarball` etc.) and then:

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
supported languages.

# Documentation
The [manual](https://goodbyekansas.github.io/nedryglot) explains how to use the different
language components. More detailed examples can be found in the examples folder.

# Contributing

[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](CODE_OF_CONDUCT.md)

We welcome contributions to this project! See the [contribution guide](CONTRIBUTING.md)
for more information.

# License

Licensed under
[BSD-3-Clause License](https://github.com/goodbyekansas/opensource-template/blob/main/LICENSE).

## Contribution

Unless you explicitly state otherwise, any contribution intentionally submitted for
inclusion in the work by you, shall be licensed as above, without any additional terms or
conditions.
