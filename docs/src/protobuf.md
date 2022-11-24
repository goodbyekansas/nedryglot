# Protobuf
Nedryglot supports generating protobuf types for any language that has
a `fromProtobuf` function in their language set. Of the languages that
Nedryglot supports, protobuf is enabled for python and rust.


# Declaring a protobuf component
The `languages` argument for `mkModule` decides which languages to
generate protobuf code for.


```nix
{ base }:
base.languages.protobuf.mkModule {
  name = "example";
  version = "1.0.0";
  src = ./.;
  languages = [ base.languages.python base.languages.rust ];
}
```


The created module has a property for each language which contains a
component that in turn contains a library with the protobuf code for
that language. This component can be used as an input to other
targets.


```nix
{ base , protocols }:
base.languages.rust.mkClient {
  name = "pruttocols";
  src = ./.;
  buildInputs = [ protocols ];
}
```


## Protobuf dependencies
When declaring a protobuf module it is possible to depend on another
protobuf module by using the `protoInputs` argument to mkModule. This
can be any component created with `base.languages.protobuf.mkModule`.

```nix
{ base, baseProtocols }:
base.languages.protobuf.mkModule {
  name = "ext";
  version = "1.0.0";
  src = ./.;
  languages = [ base.languages.python base.languages.rust ];
  protoInputs = [ baseProtocols ];
}
```


## Protobuf services
When supplying `mkModule` with `includeServices = true` grpc code will
additionally be generated for the component.
