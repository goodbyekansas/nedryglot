# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- protobuf: mkModule now has a `tools` attribute with a grpcurl wrapped with the modules
  proto files.

### Fixed
- python: Error when creating python protobuf modules.

## [5.1.2] - 2025-05-12

### Fixed
- python: Remove deprecated package ruff-lsp that is not part of the
  ruff package.

## [5.1.1] - 2024-12-18

### Fixed
- c/c++: Use more appropriate versions of clangd and clang-format when
  cross-compiling since the target platform does not actually
  matter.
- c/c++: Use a debugger for the shell that comes from buildPackages
  to get the correct hostPlatform when cross-compiling.
- c/c++: Enabling doxygen required the `name` attribute. Now,
  pname is enough as well.
- c/c++: Use a more appropriate variant of `fd`, since it
  does not depend on the target platform when cross-compiling.

## [5.1.0] - 2024-12-12

### Added
- Python now generates a `run` command and cli entry point for clients and services.

### Changed
- Python now uses `pyproject` instead of `setuptools` by default. Template for targetSetup
  has been updated accordingly. It also conforms to `ruff`s checks and formatting by default.

### Fixed
- Python's config merger now handles mypy overrides targeting multiple packages.
- C/C++ format commands used `[]` instead of `{}` in the fd glob
  expression so it matched single chars.

## [5.0.0] - 2024-10-15

### Added
- `input` parameter to `mkPlatform` for C. This controls what target
  gets used for dependent components.

### Removed
- `targetName` no longer gets sent to the `mk*` functions for C.

## [4.1.5] - 2024-09-13

### Fixed
- Overriding the factory of a C platform caused the 'override' function
  to disappear from the resulting set.
- `output` now works as expected on C platforms. Previously, setting
   output to a different value than `name` created a broken
   configuration.

## [4.1.4] - 2024-06-03

### Fixed
- Python check runner not finding config when not in root of component.
- Fix some outside tools not getting check configs because TMP is not
  always set.

## [4.1.3] - 2024-03-22

### Fixed
- Flake8 not getting configuration.

## [4.1.2] - 2024-03-22

### Fixed
- Sphinx documentation can now access the nativeBuildInputs of the source package.
- Python coverage tool not getting proper configuration.

## [4.1.1] - 2024-03-21

### Fixed
- Terraform deploy now sends sigint to terraform on ctrl+C, giving it a chance
  to shut down a little more gracefully.

## [4.1.0] - 2024-02-16

### Added
- Naming checks for the default ruff configuration.

### Fixed
- Missing shebang in python check tools. This caused errors depending
  on which exec function you used.

## [4.0.0] - 2024-02-14

### Added
- Support for overriding python linters config.

### Changed
- Ruff default configuration. Now picks upp issues similar to to the
  alternative (isort, black, flake etc).

## [3.1.0] - 2024-02-08

### Added
- Ruff support for python components. Currently have to opt in by
  setting `defaultCheckPhase = "ruffStandardTests";` on
  `base.languages.python`. This will change the global default for the
  python language. To set it for a single component set
  `installCheckPhase` to `standardTests` or `ruffStandardTests` or any
  combination of the two. To individually set the formatter set the
  `formatter` on the component to either "standard" (black + isort) or
  to "ruff" (ruff 🐕). If formatter is not set it will be detected from the value of `installCheckPhase`.

## [3.0.0] - 2024-02-06

### Added
- `gen-default-crates` command to generate the list of default crates shipped with
  Nedryglot.
- Support for nixpkgs versions up to 23.11

### Changed
- Now uses Nedryland version 10.0.0

## [2.0.1] - 2023-12-05

### Fixed
- C does not expect `doc` and `man` output if doxygen is disabled.
- C platform override now lets the user override all attributes of the derivation, not
  just the attributes sent in. For example, `lintPhase` was hardcoded in `mkDerivation`
  for all C platforms.

## [2.0.0] - 2023-11-07

### Added
- `build` shell command for python.

### Fixed
- Terraform deploy will now exit with non-zero exit code if deploy failed.
- Give pylint a $HOME so it won't complain when writing cache and stats.

### Changed
- Nedryglot now requires version 9.0.0 of nedryland or higher.
- Python linting tools now combines their configs during runtime instead of build time.
- Rust components now only uses vendored dependencies. Dependencies
  can be vendored with the `fetchCrate` function. Refer to the docs
  for more information.

## [1.2.2] - 2023-06-9

### Fixed
- Config merge script including non mypy settings for mypy.

## [1.2.1] - 2023-06-1

### Fixed
- Config merge script not considering if certain fields did not exist.

## [1.2.0] - 2023-05-31

### Added
- Add support for supplying python check tools with arguments (black,
  isort, pylint, flake8, mypy, pytest)

### Fixed
- mypy overrides not working in for example pyproject.toml.

## [1.1.0] - 2023-04-21

### Added
- docsConfig added for python components.
- C/C++ as a supported language. The language currently makes no assumptions on build system.
  See the documentation for more information.

### Fixed
- Fixed black nix store check.
- Make sure python check tool runners has a shell shebang.

## [1.0.3] - 2023-02-06

### Fixed
- Disabled black on aarch64-darwin since it is broken in nixpkgs 22.05.
- Hide check command if checks are not available.

### Changed
- The merged/generated configs for python's linters do not check the filesystem during nix eval.

### Added
- Tests for nixpkgs 22.11

## [1.0.2] - 2023-01-17

### Fixed
- Python checks were accidentally left off, they are now on by default.

## [1.0.1] - 2023-01-13

### Fixed
- Python version check to use the correct attribute and check for non-Nedryland components.

## [1.0.0] - 2023-01-11

### Added
- Broke out languages from Nedryland into Nedryglot with notable changes:
  - All languages can be overridden.
  - Added shell setup for terraform language.
  - New and updated documentation.
  - New examples.
  - Python language now supports several versions of python. Creates one target per version.
  - Rust language now uses rust from nixpkgs by default.
  - Languages no longer uses the generic `package` attribute. There shouldn't be any blessed targets or assumptions.
