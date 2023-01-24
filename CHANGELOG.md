# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed
- Disabled black on aarch64-darwin since it is broken in nixpkgs 22.05.
- Hide check command if checks are not available.
- Terraform runs checks by default.
- Terraform kept the pre- and postDeploy on the derivation, now they are only on the deployment.
  This way the terraform target is not dependent on things in pre/post deploy.
- Terraform, move terraform itself from buildInputs to nativeBuildInputs.

### Added
- Tests for nixpkgs 22.11.
- Terraform uses a lintPhase and runs preList/postList.
- Terraform can take custom checkPhase to insert after the standard checks and preCheck/postCheck.


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
