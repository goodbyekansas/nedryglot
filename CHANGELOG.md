# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Add support for supplying python check tools with arguments (black,
  isort, pylint, flake8, mypy, pytest)

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
