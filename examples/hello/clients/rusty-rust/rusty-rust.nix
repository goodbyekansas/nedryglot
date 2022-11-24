{ base }:
# Superslim rust client. Remove all extra targets.
(base.languages.rust.override { crossTargets = { }; }).mkClient {
  name = "rusty-rust";
  src = ./.;
}
