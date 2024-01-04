fetchCrate: rec{

  ansi_term = fetchCrate {
    name = "ansi_term";
    version = "0.12.1";
    sha256 = "d52a9bb7ec0cf484c551830a7ce27bd20d67eac647e1befb56b0be4ee39a55d2";
    deps = [ ];
  };

  anstyle = fetchCrate {
    name = "anstyle";
    version = "1.0.4";
    sha256 = "7079075b41f533b8c61d2a4d073c4676e1f8b249ff94a393b0595db304e0dd87";
    deps = [ ];
  };

  anyhow = fetchCrate {
    name = "anyhow";
    version = "1.0.75";
    sha256 = "a4668cab20f66d8d020e1fbc0ebe47217433c1b6c8f2040faf858554e394ace6";
    deps = [ ];
  };

  atty = fetchCrate {
    name = "atty";
    version = "0.2.14";
    sha256 = "d9b39be18770d11421cdb1b9947a45dd3f37e93092cbf377614828a319d5fee8";
    deps = [ hermit-abi_0_1 libc winapi ];
  };

  bitflags = fetchCrate {
    name = "bitflags";
    version = "2.4.1";
    sha256 = "327762f6e5a765692301e5bb513e0d9fef63be86bbc14528052b1cd3e6f03e07";
    deps = [ ];
  };

  bitflags_1 = fetchCrate {
    name = "bitflags";
    version = "1.3.2";
    sha256 = "bef38d45163c2f1dde094a7dfd33ccf595c92905c8f8f4fdc18d06fb1037718a";
    deps = [ ];
  };

  bytes = fetchCrate {
    name = "bytes";
    version = "1.5.0";
    sha256 = "a2bd12c1caf447e69cd4528f47f94d203fd2582878ecb9e9465484c4148a8223";
    deps = [ ];
  };

  cfg-if = fetchCrate {
    name = "cfg-if";
    version = "1.0.0";
    sha256 = "baf1de4339761588bc0619e3cbc0120ee582ebb74b53b4efbf79117bd2da40fd";
    deps = [ ];
  };

  clap = fetchCrate {
    name = "clap";
    version = "4.4.13";
    sha256 = "52bdc885e4cacc7f7c9eedc1ef6da641603180c783c41a15c264944deeaab642";
    deps = [ clap_builder ];
  };

  clap_2 = fetchCrate {
    name = "clap";
    version = "2.34.0";
    sha256 = "a0610544180c38b88101fecf2dd634b174a62eef6946f84dfc6a7127512b381c";
    deps = [ ansi_term atty bitflags_1 strsim_0_8 textwrap unicode-width vec_map ];
  };

  clap_builder = fetchCrate {
    name = "clap_builder";
    version = "4.4.12";
    sha256 = "fb7fb5e4e979aec3be7791562fcba452f94ad85e954da024396433e0e25a79e9";
    deps = [ anstyle clap_lex ];
  };

  clap_lex = fetchCrate {
    name = "clap_lex";
    version = "0.6.0";
    sha256 = "702fc72eb24e5a1e48ce58027a675bc24edd52096d5397d4aea7c6dd9eca0bd1";
    deps = [ ];
  };

  dirs = fetchCrate {
    name = "dirs";
    version = "5.0.1";
    sha256 = "44c45a9d03d6676652bcb5e724c7e988de1acad23a711b5217ab9cbecbec2225";
    deps = [ dirs-sys ];
  };

  dirs-next = fetchCrate {
    name = "dirs-next";
    version = "2.0.0";
    sha256 = "b98cf8ebf19c3d1b223e151f99a4f9f0690dca41414773390fc824184ac833e1";
    deps = [ cfg-if dirs-sys-next ];
  };

  dirs-sys = fetchCrate {
    name = "dirs-sys";
    version = "0.4.1";
    sha256 = "520f05a5cbd335fae5a99ff7a6ab8627577660ee5cfd6a94a6a929b52ff0321c";
    deps = [ libc option-ext ];
  };

  dirs-sys-next = fetchCrate {
    name = "dirs-sys-next";
    version = "0.1.2";
    sha256 = "4ebda144c4fe02d1f7ea1a7d9641b6fc6b580adcfa024ae48797ecdeb6825b4d";
    deps = [ libc ];
  };

  either = fetchCrate {
    name = "either";
    version = "1.9.0";
    sha256 = "a26ae43d7bcc3b814de94796a5e736d4029efb0ee900c12e2d54c993ad1a1e07";
    deps = [ ];
  };

  equivalent = fetchCrate {
    name = "equivalent";
    version = "1.0.1";
    sha256 = "5443807d6dff69373d433ab9ef5378ad8df50ca6298caf15de6e52e24aaf54d5";
    deps = [ ];
  };

  errno = fetchCrate {
    name = "errno";
    version = "0.3.8";
    sha256 = "a258e46cdc063eb8519c00b9fc845fc47bcfca4130e2f08e88665ceda8474245";
    deps = [ libc ];
  };

  fastrand = fetchCrate {
    name = "fastrand";
    version = "2.0.1";
    sha256 = "25cbce373ec4653f1a01a31e8a5e5ec0c622dc27ff9c4e6606eefef5cbbed4a5";
    deps = [ ];
  };

  fixedbitset = fetchCrate {
    name = "fixedbitset";
    version = "0.4.2";
    sha256 = "0ce7134b9999ecaf8bcd65542e436736ef32ddca1b3e06094cb6ec5755203b80";
    deps = [ ];
  };

  hashbrown = fetchCrate {
    name = "hashbrown";
    version = "0.14.3";
    sha256 = "290f1a1d9242c78d09ce40a5e87e7554ee637af1351968159f4952f028f75604";
    deps = [ ];
  };

  heck = fetchCrate {
    name = "heck";
    version = "0.4.1";
    sha256 = "95505c38b4572b2d910cecb0281560f54b440a19336cbbcb27bf6ce6adc6f5a8";
    deps = [ ];
  };

  heck_0_3 = fetchCrate {
    name = "heck";
    version = "0.3.3";
    sha256 = "6d621efb26863f0e9924c6ac577e8275e5e6b77455db64ffa6c65c904e9e132c";
    deps = [ unicode-segmentation ];
  };

  hermit-abi_0_1 = fetchCrate {
    name = "hermit-abi";
    version = "0.1.20";
    sha256 = "c7a30908dbce072eca83216eab939d2290080e00ca71611b96a09e5cdce5f3fa";
    deps = [ ];
  };

  home = fetchCrate {
    name = "home";
    version = "0.5.9";
    sha256 = "e3d1354bf6b7235cb4a0576c2619fd4ed18183f689b12b006a0ee7329eeff9a5";
    deps = [ ];
  };

  indexmap = fetchCrate {
    name = "indexmap";
    version = "2.1.0";
    sha256 = "d530e1a18b1cb4c484e6e34556a0d948706958449fca0cab753d649f2bce3d1f";
    deps = [ equivalent hashbrown ];
  };

  itertools = fetchCrate {
    name = "itertools";
    version = "0.11.0";
    sha256 = "b1c173a5686ce8bfa551b3563d0c2170bf24ca44da99c7ca4bfdab5418c3fe57";
    deps = [ either ];
  };

  lazy_static = fetchCrate {
    name = "lazy_static";
    version = "1.4.0";
    sha256 = "e2abad23fbc42b3700f2f279844dc832adb2b2eb069b2df918f455c4e18cc646";
    deps = [ ];
  };

  libc = fetchCrate {
    name = "libc";
    version = "0.2.151";
    sha256 = "302d7ab3130588088d277783b1e2d2e10c9e9e4a16dd9050e6ec93fb3e7048f4";
    deps = [ ];
  };

  linux-raw-sys = fetchCrate {
    name = "linux-raw-sys";
    version = "0.4.12";
    sha256 = "c4cd1a83af159aa67994778be9070f0ae1bd732942279cabb14f86f986a21456";
    deps = [ ];
  };

  log = fetchCrate {
    name = "log";
    version = "0.4.20";
    sha256 = "b5e6163cb8c49088c2c36f57875e58ccd8c87c7427f7fbd50ea6710b2f3f2e8f";
    deps = [ ];
  };

  multimap = fetchCrate {
    name = "multimap";
    # pinned for prost-build
    version = "0.8.3";
    sha256 = "e5ce46fe64a9d73be07dcbe690a38ce1b293be448fd8ce1e6c1b8062c9f72c6a";
    deps = [ ];
  };

  once_cell = fetchCrate {
    name = "once_cell";
    version = "1.19.0";
    sha256 = "3fdb12b2476b595f9358c5161aa467c2438859caa136dec86c26fdd2efe17b92";
    deps = [ ];
  };

  option-ext = fetchCrate {
    name = "option-ext";
    version = "0.2.0";
    sha256 = "04744f49eae99ab78e0d5c0b603ab218f515ea8cfe5a456d7629ad883a3b6e7d";
    deps = [ ];
  };

  petgraph = fetchCrate {
    name = "petgraph";
    version = "0.6.4";
    sha256 = "e1d3afd2628e69da2be385eb6f2fd57c8ac7977ceeff6dc166ff1657b0e386a9";
    deps = [ fixedbitset indexmap ];
  };

  prettyplease = fetchCrate {
    name = "prettyplease";
    version = "0.2.16";
    sha256 = "a41cf62165e97c7f814d2221421dbb9afcbcdb0a88068e5ea206e19951c2cbb5";
    deps = [ proc-macro2 syn ];
  };

  proc-macro-error = fetchCrate {
    name = "proc-macro-error";
    version = "1.0.4";
    sha256 = "da25490ff9892aab3fcf7c36f08cfb902dd3e71ca0f9f9517bea02a73a5ce38c";
    deps = [ proc-macro-error-attr proc-macro2 quote version_check ];
  };

  proc-macro-error-attr = fetchCrate {
    name = "proc-macro-error-attr";
    version = "1.0.4";
    sha256 = "a1be40180e52ecc98ad80b184934baf3d0d29f979574e439af5a55274b35f869";
    deps = [ proc-macro2 quote version_check ];
  };

  proc-macro2 = fetchCrate {
    name = "proc-macro2";
    version = "1.0.75";
    sha256 = "907a61bd0f64c2f29cd1cf1dc34d05176426a3f504a78010f08416ddb7b13708";
    deps = [ unicode-ident ];
  };

  prost = fetchCrate {
    name = "prost";
    version = "0.12.3";
    sha256 = "146c289cda302b98a28d40c8b3b90498d6e526dd24ac2ecea73e4e491685b94a";
    deps = [ bytes prost-derive ];
  };

  prost-build = fetchCrate {
    name = "prost-build";
    version = "0.12.3";
    sha256 = "c55e02e35260070b6f716a2423c2ff1c3bb1642ddca6f99e1f26d06268a0e2d2";
    deps = [ bytes heck itertools log multimap once_cell petgraph prost prost-types regex_1_8 tempfile which ];
  };

  prost-derive = fetchCrate {
    name = "prost-derive";
    version = "0.12.3";
    sha256 = "efb6c9a1dd1def8e2124d17e83a20af56f1570d6c2d2bd9e266ccb768df3840e";
    deps = [ anyhow ];
  };

  prost-types = fetchCrate {
    name = "prost-types";
    version = "0.12.3";
    sha256 = "193898f59edcf43c26227dcd4c8427f00d99d61e95dcde58dabd49fa291d470e";
    deps = [ prost ];
  };

  quote = fetchCrate {
    name = "quote";
    version = "1.0.35";
    sha256 = "291ec9ab5efd934aaf503a6466c5d5251535d108ee747472c3977cc5acc868ef";
    deps = [ proc-macro2 ];
  };

  redox_syscall = fetchCrate {
    name = "redox_syscall";
    version = "0.4.1";
    sha256 = "4722d768eff46b75989dd134e5c353f0d6296e5aaa3132e776cbdb56be7731aa";
    deps = [ bitflags ];
  };

  regex = fetchCrate {
    name = "regex";
    version = "1.10.2";
    sha256 = "380b951a9c5e80ddfd6136919eef32310721aa4aacd4889a8d39124b026ab343";
    deps = [ regex-automata regex-syntax ];
  };

  regex_1_8 = fetchCrate {
    name = "regex";
    version = "1.8.4";
    sha256 = "d0ab3ca65655bb1e41f2a8c8cd662eb4fb035e67c3f78da1d61dffe89d07300f";
    deps = [ regex-syntax_0_7 ];
  };

  regex-automata = fetchCrate {
    name = "regex-automata";
    version = "0.4.3";
    sha256 = "5f804c7828047e88b2d32e2d7fe5a105da8ee3264f01902f796c8e067dc2483f";
    deps = [ ];
  };

  regex-syntax = fetchCrate {
    name = "regex-syntax";
    version = "0.8.2";
    sha256 = "c08c74e62047bb2de4ff487b251e4a92e24f48745648451635cec7d591162d9f";
    deps = [ ];
  };

  regex-syntax_0_7 = fetchCrate {
    name = "regex-syntax";
    version = "0.7.3";
    sha256 = "2ab07dc67230e4a4718e70fd5c20055a4334b121f1f9db8fe63ef39ce9b8c846";
    deps = [ ];
  };

  rustix = fetchCrate {
    name = "rustix";
    version = "0.38.28";
    sha256 = "72e572a5e8ca657d7366229cdde4bd14c4eb5499a9573d4d366fe1b599daa316";
    deps = [ bitflags errno libc linux-raw-sys ];
  };

  strsim_0_8 = fetchCrate {
    name = "strsim";
    version = "0.8.0";
    sha256 = "8ea5119cdb4c55b55d432abb513a0429384878c15dde60cc77b1c99de1a95a6a";
    deps = [ ];
  };

  structopt = fetchCrate {
    name = "structopt";
    version = "0.3.26";
    sha256 = "0c6b5c64445ba8094a6ab0c3cd2ad323e07171012d9c98b0b15651daf1787a10";
    deps = [ clap_2 lazy_static structopt-derive ];
  };

  structopt-derive = fetchCrate {
    name = "structopt-derive";
    version = "0.4.18";
    sha256 = "dcb5ae327f9cc13b68763b5749770cb9e048a99bd9dfdfa58d0cf05d5f64afe0";
    deps = [ heck_0_3 proc-macro-error proc-macro2 quote syn_1 ];
  };

  syn = fetchCrate {
    name = "syn";
    version = "2.0.48";
    sha256 = "0f3531638e407dfc0814761abb7c00a5b54992b849452a0646b7f65c9f770f3f";
    deps = [ proc-macro2 unicode-ident ];
  };

  syn_1 = fetchCrate {
    name = "syn";
    version = "1.0.109";
    sha256 = "72b64191b275b66ffe2469e8af2c1cfe3bafa67b529ead792a6d0160888b4237";
    deps = [ ];
  };

  tempfile = fetchCrate {
    name = "tempfile";
    version = "3.9.0";
    sha256 = "01ce4141aa927a6d1bd34a041795abd0db1cccba5d5f24b009f694bdf3a1f3fa";
    deps = [ cfg-if fastrand rustix redox_syscall windows-sys ];
  };

  textwrap = fetchCrate {
    name = "textwrap";
    version = "0.11.0";
    sha256 = "d326610f408c7a4eb6f51c37c330e496b08506c9457c9d34287ecc38809fb060";
    deps = [ ];
  };

  tonic-build = fetchCrate {
    name = "tonic-build";
    version = "0.10.2";
    sha256 = "9d021fc044c18582b9a2408cd0dd05b1596e3ecdb5c4df822bb0183545683889";
    deps = [ prettyplease proc-macro2 quote syn ];
  };

  unicode-ident = fetchCrate {
    name = "unicode-ident";
    version = "1.0.12";
    sha256 = "3354b9ac3fae1ff6755cb6db53683adb661634f67557942dea4facebec0fee4b";
    deps = [ ];
  };

  unicode-segmentation = fetchCrate {
    name = "unicode-segmentation";
    version = "1.10.1";
    sha256 = "1dd624098567895118886609431a7c3b8f516e41d30e0643f03d94592a147e36";
    deps = [ ];
  };

  unicode-width = fetchCrate {
    name = "unicode-width";
    version = "0.1.11";
    sha256 = "e51733f11c9c4f72aa0c160008246859e340b00807569a0da0e7a1079b27ba85";
    deps = [ ];
  };

  vec_map = fetchCrate {
    name = "vec_map";
    version = "0.8.2";
    sha256 = "f1bddf1187be692e79c5ffeab891132dfb0f236ed36a43c7ed39f1165ee20191";
    deps = [ ];
  };

  version_check = fetchCrate {
    name = "version_check";
    version = "0.9.4";
    sha256 = "49874b5167b65d7193b8aba1567f5c7d93d001cafc34600cee003eda787e483f";
    deps = [ ];
  };

  which = fetchCrate {
    name = "which";
    # pinned because of rustix and prost-build
    version = "4.4.0";
    sha256 = "2441c784c52b289a054b7201fc93253e288f094e2f4be9058343127c4226a269";
    deps = [ dirs either once_cell ];
  };

  winapi = fetchCrate {
    name = "winapi";
    version = "0.3.9";
    sha256 = "5c839a674fcd7a98952e593242ea400abe93992746761e38641405d28b00f419";
    deps = [ winapi-i686-pc-windows-gnu winapi-x86_64-pc-windows-gnu ];
  };

  winapi-i686-pc-windows-gnu = fetchCrate {
    name = "winapi-i686-pc-windows-gnu";
    version = "0.4.0";
    sha256 = "ac3b87c63620426dd9b991e5ce0329eff545bccbbb34f3be09ff6fb6ab51b7b6";
    deps = [ ];
  };

  winapi-x86_64-pc-windows-gnu = fetchCrate {
    name = "winapi-x86_64-pc-windows-gnu";
    version = "0.4.0";
    sha256 = "712e227841d057c1ee1cd2fb22fa7e5a5461ae8e48fa2ca79ec42cfc1931183f";
    deps = [ ];
  };

  windows-sys = fetchCrate {
    name = "windows-sys";
    version = "0.52.0";
    sha256 = "282be5f36a8ce781fad8c8ae18fa3f9beff57ec1b52cb3de0789201425d9a33d";
    deps = [ windows-targets ];
  };

  windows-targets = fetchCrate {
    name = "windows-targets";
    version = "0.52.0";
    sha256 = "8a18201040b24831fbb9e4eb208f8892e1f50a37feb53cc7ff887feb8f50e7cd";
    deps = [ windows_aarch64_gnullvm windows_aarch64_msvc windows_i686_gnu windows_i686_msvc windows_x86_64_gnu windows_x86_64_gnullvm windows_x86_64_msvc ];
  };

  windows_aarch64_gnullvm = fetchCrate {
    name = "windows_aarch64_gnullvm";
    version = "0.52.0";
    sha256 = "cb7764e35d4db8a7921e09562a0304bf2f93e0a51bfccee0bd0bb0b666b015ea";
    deps = [ ];
  };

  windows_aarch64_msvc = fetchCrate {
    name = "windows_aarch64_msvc";
    version = "0.52.0";
    sha256 = "bbaa0368d4f1d2aaefc55b6fcfee13f41544ddf36801e793edbbfd7d7df075ef";
    deps = [ ];
  };

  windows_i686_gnu = fetchCrate {
    name = "windows_i686_gnu";
    version = "0.52.0";
    sha256 = "a28637cb1fa3560a16915793afb20081aba2c92ee8af57b4d5f28e4b3e7df313";
    deps = [ ];
  };

  windows_i686_msvc = fetchCrate {
    name = "windows_i686_msvc";
    version = "0.52.0";
    sha256 = "ffe5e8e31046ce6230cc7215707b816e339ff4d4d67c65dffa206fd0f7aa7b9a";
    deps = [ ];
  };

  windows_x86_64_gnu = fetchCrate {
    name = "windows_x86_64_gnu";
    version = "0.52.0";
    sha256 = "3d6fa32db2bc4a2f5abeacf2b69f7992cd09dca97498da74a151a3132c26befd";
    deps = [ ];
  };

  windows_x86_64_gnullvm = fetchCrate {
    name = "windows_x86_64_gnullvm";
    version = "0.52.0";
    sha256 = "1a657e1e9d3f514745a572a6846d3c7aa7dbe1658c056ed9c3344c4109a6949e";
    deps = [ ];
  };

  windows_x86_64_msvc = fetchCrate {
    name = "windows_x86_64_msvc";
    version = "0.52.0";
    sha256 = "dff9641d1cd4be8d1a070daf9e3773c5f67e78b4d9d42263020c057706765c04";
    deps = [ ];
  };
}
