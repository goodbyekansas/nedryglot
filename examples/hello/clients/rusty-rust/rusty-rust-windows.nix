{ base }:
# Rust client where the rust target is windows.
(base.languages.rust.overrideCrossTargets (existingTargets: {
  rust = existingTargets.windows;
})).mkClient {
  name = "rusty-rust-windows";
  src = ./.;
  executableName = "rusty-rust";
}
