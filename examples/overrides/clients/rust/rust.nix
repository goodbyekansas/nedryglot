{ base }:
base.languages.rust.mkClient {
  name = "rostig-kund";
  version = "0.1.0";
  src = ./.;
}
