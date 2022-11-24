# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Broke out languages from Nedryland into Nedryglot with notable changes:
  - All languages can be overridden.
  - Added shell setup for terraform language.
  - New and updated documentation.
  - New examples.
  - Python language now supports several versions of python. Creates one target per version.
  - Rust language now uses rust from nixpkgs by default.
  - Languages no longer uses the generic `package` attribute. There shouldn't be any blessed targets or assumptions.
