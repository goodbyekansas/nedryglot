{ base, protocols }:
base.languages.rust.mkClient {
  name = "rust-client";
  buildInputs = [ protocols.rust ];
  src = ./.;
  externalDependenciesHash = "sha256-OwxIfRrYeqMFYrtBZ9s6BIk6ifUazhvNwiWImxdhUBw=";
}
