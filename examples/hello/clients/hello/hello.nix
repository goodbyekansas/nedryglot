# numpyWrapper is automatically passed in
# since there is a component with the same name
{ base, numpyWrapper }:

base.languages.python.mkClient {
  name = "hello";
  version = "1.0.0";
  src = ./.;
  # Here we just use numpyWrapper since it's our own
  # package and not part of the python version packages.
  propagatedBuildInputs = [ numpyWrapper ];
  installCheckPhase = "ruffStandardTests";
}
