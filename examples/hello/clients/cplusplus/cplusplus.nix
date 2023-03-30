{ base, tree }:
base.languages.c.mkClient ({ libunistring, pkg-config }: {
  name = "cplusplus";
  version = "1.0.2";

  buildInputs = [ libunistring ];
  nativeBuildInputs = [ pkg-config tree ];
  executable = "./up";
  src = ./.;
})
