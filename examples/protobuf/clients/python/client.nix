{ base, protocols }:
base.languages.python.mkClient {
  name = "python-client";
  version = "1.0.0";
  propagatedBuildInputs = _: [ protocols.python ];
  src = ./.;
}
