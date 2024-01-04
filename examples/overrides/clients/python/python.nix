{ base }:
base.languages.python.mkClient {
  name = "ormgrop";
  version = "10.3.1";
  src = ./.;
}
