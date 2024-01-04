fetchCrate: rec{
  addr2line = fetchCrate {
    name = "addr2line";
    version = "0.21.0";
    sha256 = "8a30b2e23b9e17a9f90641c7ab1549cd9b44f296d3ccbf309d2863cfe398a0cb";
    deps = [ gimli ];
  };

  adler = fetchCrate {
    name = "adler";
    version = "1.0.2";
    sha256 = "f26201604c87b1e01bd3d98f8d5d9a8fcbb815e8cedb41ffccbeb4bf593a35fe";
    deps = [ ];
  };

  ahash = fetchCrate {
    name = "ahash";
    version = "0.8.7";
    sha256 = "77c3a9648d43b9cd48db467b3f87fdd6e146bcc88ab0180006cef2179fe11d01";
    deps = [ cfg-if once_cell version_check zerocopy ];
  };

  aho-corasick = fetchCrate {
    name = "aho-corasick";
    version = "1.1.2";
    sha256 = "b2969dcb958b36655471fc61f7e416fa76033bdd4bfed0678d8fee1e2d07a1f0";
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
    version = "1.0.79";
    sha256 = "080e9890a082662b09c1ad45f567faeeb47f22b5fb23895fbe1e651e718e25ca";
    deps = [ ];
  };

  atty = fetchCrate {
    name = "atty";
    version = "0.2.14";
    sha256 = "d9b39be18770d11421cdb1b9947a45dd3f37e93092cbf377614828a319d5fee8";
    deps = [ hermit-abi libc winapi ];
  };

  autocfg = fetchCrate {
    name = "autocfg";
    version = "1.1.0";
    sha256 = "d468802bab17cbc0cc575e9b053f41e72aa36bfa6b7f55e3529ffa43161b97fa";
    deps = [ ];
  };

  backtrace = fetchCrate {
    name = "backtrace";
    version = "0.3.69";
    sha256 = "2089b7e3f35b9dd2d0ed921ead4f6d318c27680d4a5bd167b3ee120edb105837";
    deps = [ addr2line cc cfg-if libc miniz_oxide object rustc-demangle ];
  };

  base64 = fetchCrate {
    name = "base64";
    version = "0.21.6";
    sha256 = "c79fed4cdb43e993fcdadc7e58a09fd0e3e649c4436fa11da71c9f1f3ee7feb9";
    deps = [ ];
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

  block-buffer = fetchCrate {
    name = "block-buffer";
    version = "0.10.4";
    sha256 = "3078c7629b62d3f0439517fa394996acacc5cbc91c5a20d8c658e77abd503a71";
    deps = [ generic-array ];
  };

  byteorder = fetchCrate {
    name = "byteorder";
    version = "1.5.0";
    sha256 = "1fd0f2584146f6f2ef48085050886acf353beff7305ebd1ae69500e27c67f64b";
    deps = [ ];
  };

  bytes = fetchCrate {
    name = "bytes";
    version = "1.5.0";
    sha256 = "a2bd12c1caf447e69cd4528f47f94d203fd2582878ecb9e9465484c4148a8223";
    deps = [ ];
  };

  cc = fetchCrate {
    name = "cc";
    version = "1.0.83";
    sha256 = "f1174fb0b6ec23863f8b971027804a42614e347eafb0a95bf0b12cdae21fc4d0";
    deps = [ libc ];
  };

  cfg-if = fetchCrate {
    name = "cfg-if";
    version = "1.0.0";
    sha256 = "baf1de4339761588bc0619e3cbc0120ee582ebb74b53b4efbf79117bd2da40fd";
    deps = [ ];
  };

  chrono = fetchCrate {
    name = "chrono";
    version = "0.4.31";
    sha256 = "7f2c685bad3eb3d45a01354cedb7d5faa66194d1d58ba6e267a8de788f79db38";
    deps = [ num-traits ];
  };

  clap = fetchCrate {
    name = "clap";
    version = "4.4.14";
    sha256 = "33e92c5c1a78c62968ec57dbc2440366a2d6e5a23faf829970ff1585dc6b18e2";
    deps = [ clap_builder ];
  };

  clap_builder = fetchCrate {
    name = "clap_builder";
    version = "4.4.14";
    sha256 = "f4323769dc8a61e2c39ad7dc26f6f2800524691a44d74fe3d1071a5c24db6370";
    deps = [ anstyle clap_lex ];
  };

  clap_lex = fetchCrate {
    name = "clap_lex";
    version = "0.6.0";
    sha256 = "702fc72eb24e5a1e48ce58027a675bc24edd52096d5397d4aea7c6dd9eca0bd1";
    deps = [ ];
  };

  cpufeatures = fetchCrate {
    name = "cpufeatures";
    version = "0.2.12";
    sha256 = "53fe5e26ff1b7aef8bca9c6080520cfb8d9333c7568e1829cef191a9723e5504";
    deps = [ libc ];
  };

  crossbeam-channel = fetchCrate {
    name = "crossbeam-channel";
    version = "0.5.11";
    sha256 = "176dc175b78f56c0f321911d9c8eb2b77a78a4860b9c19db83835fea1a46649b";
    deps = [ crossbeam-utils ];
  };

  crossbeam-epoch = fetchCrate {
    name = "crossbeam-epoch";
    version = "0.9.18";
    sha256 = "5b82ac4a3c2ca9c3460964f020e1402edd5753411d7737aa39c3714ad1b5420e";
    deps = [ crossbeam-utils ];
  };

  crossbeam-utils = fetchCrate {
    name = "crossbeam-utils";
    version = "0.8.19";
    sha256 = "248e3bacc7dc6baa3b21e405ee045c3047101a49145e7e9eca583ab4c2ca5345";
    deps = [ ];
  };

  crypto-common = fetchCrate {
    name = "crypto-common";
    version = "0.1.6";
    sha256 = "1bfb12502f3fc46cca1bb51ac28df9d618d813cdc3d2f25b9fe775a34af26bb3";
    deps = [ generic-array typenum ];
  };

  deranged = fetchCrate {
    name = "deranged";
    version = "0.3.11";
    sha256 = "b42b6fa04a440b495c8b04d0e71b707c585f83cb9cb28cf8cd0d976c315e31b4";
    deps = [ ];
  };

  digest = fetchCrate {
    name = "digest";
    version = "0.10.7";
    sha256 = "9ed9a281f7bc9b7576e61468ba615a66a5c8cfdff42420a70aa82701a3b1e292";
    deps = [ crypto-common ];
  };

  either = fetchCrate {
    name = "either";
    version = "1.9.0";
    sha256 = "a26ae43d7bcc3b814de94796a5e736d4029efb0ee900c12e2d54c993ad1a1e07";
    deps = [ ];
  };

  env_logger = fetchCrate {
    name = "env_logger";
    version = "0.10.1";
    sha256 = "95b3f3e67048839cb0d0781f445682a35113da7121f7c949db0e2be96a4fbece";
    deps = [ log ];
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
    deps = [ libc windows-sys ];
  };

  fastrand = fetchCrate {
    name = "fastrand";
    version = "2.0.1";
    sha256 = "25cbce373ec4653f1a01a31e8a5e5ec0c622dc27ff9c4e6606eefef5cbbed4a5";
    deps = [ ];
  };

  fnv = fetchCrate {
    name = "fnv";
    version = "1.0.7";
    sha256 = "3f9eec918d3f24069decb9af1554cad7c880e2da24a9afd88aca000531ab82c1";
    deps = [ ];
  };

  form_urlencoded = fetchCrate {
    name = "form_urlencoded";
    version = "1.2.1";
    sha256 = "e13624c2627564efccf4934284bdd98cbaa14e79b0b5a141218e507b3a823456";
    deps = [ percent-encoding ];
  };

  futures = fetchCrate {
    name = "futures";
    version = "0.3.30";
    sha256 = "645c6916888f6cb6350d2550b80fb63e734897a8498abe35cfb732b6487804b0";
    deps = [ futures-channel futures-core futures-io futures-sink futures-task futures-util ];
  };

  futures-channel = fetchCrate {
    name = "futures-channel";
    version = "0.3.30";
    sha256 = "eac8f7d7865dcb88bd4373ab671c8cf4508703796caa2b1985a9ca867b3fcb78";
    deps = [ futures-core ];
  };

  futures-core = fetchCrate {
    name = "futures-core";
    version = "0.3.30";
    sha256 = "dfc6580bb841c5a68e9ef15c77ccc837b40a7504914d52e47b8b0e9bbda25a1d";
    deps = [ ];
  };

  futures-io = fetchCrate {
    name = "futures-io";
    version = "0.3.30";
    sha256 = "a44623e20b9681a318efdd71c299b6b222ed6f231972bfe2f224ebad6311f0c1";
    deps = [ ];
  };

  futures-sink = fetchCrate {
    name = "futures-sink";
    version = "0.3.30";
    sha256 = "9fb8e00e87438d937621c1c6269e53f536c14d3fbd6a042bb24879e57d474fb5";
    deps = [ ];
  };

  futures-task = fetchCrate {
    name = "futures-task";
    version = "0.3.30";
    sha256 = "38d84fa142264698cdce1a9f9172cf383a0c82de1bddcf3092901442c4097004";
    deps = [ ];
  };

  futures-util = fetchCrate {
    name = "futures-util";
    version = "0.3.30";
    sha256 = "3d6401deb83407ab3da39eba7e33987a73c3df0c82b4bb5813ee871c19c41d48";
    deps = [ futures-core futures-task pin-project-lite pin-utils ];
  };

  generic-array = fetchCrate {
    name = "generic-array";
    version = "1.0.0";
    sha256 = "fe739944a5406424e080edccb6add95685130b9f160d5407c639c7df0c5836b0";
    deps = [ typenum ];
  };

  getrandom = fetchCrate {
    name = "getrandom";
    version = "0.2.12";
    sha256 = "190092ea657667030ac6a35e305e62fc4dd69fd98ac98631e5d3a2b1575a12b5";
    deps = [ cfg-if libc wasi ];
  };

  gimli = fetchCrate {
    name = "gimli";
    version = "0.28.1";
    sha256 = "4271d37baee1b8c7e4b708028c57d816cf9d2434acb33a549475f78c181f6253";
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

  hermit-abi = fetchCrate {
    name = "hermit-abi";
    version = "0.3.3";
    sha256 = "d77f7ec81a6d05a3abb01ab6eb7590f6083d08449fe5a1c8b1e620283546ccb7";
    deps = [ ];
  };

  http = fetchCrate {
    name = "http";
    version = "1.0.0";
    sha256 = "b32afd38673a8016f7c9ae69e5af41a58f81b1d31689040f2f1959594ce194ea";
    deps = [ bytes fnv itoa ];
  };

  http-body = fetchCrate {
    name = "http-body";
    version = "1.0.0";
    sha256 = "1cac85db508abc24a2e48553ba12a996e87244a0395ce011e62b37158745d643";
    deps = [ bytes http ];
  };

  hyper = fetchCrate {
    name = "hyper";
    version = "1.1.0";
    sha256 = "fb5aa53871fc917b1a9ed87b683a5d86db645e23acb32c2e0785a353e522fb75";
    deps = [ bytes http http-body pin-project-lite tokio ];
  };

  idna = fetchCrate {
    name = "idna";
    version = "0.5.0";
    sha256 = "634d9b1461af396cad843f47fdba5597a4f9e6ddd4bfb6ff5d85028c25cb12f6";
    deps = [ unicode-bidi unicode-normalization ];
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

  itoa = fetchCrate {
    name = "itoa";
    version = "1.0.10";
    sha256 = "b1a46d1a171d865aa5f83f92695765caa047a9b4cbae2cbf37dbd613a793fd4c";
    deps = [ ];
  };

  lazy_static = fetchCrate {
    name = "lazy_static";
    version = "1.4.0";
    sha256 = "e2abad23fbc42b3700f2f279844dc832adb2b2eb069b2df918f455c4e18cc646";
    deps = [ ];
  };

  libc = fetchCrate {
    name = "libc";
    version = "0.2.152";
    sha256 = "13e3bf6590cbc649f4d1a3eefc9d5d6eb746f5200ffb04e5e142700b8faa56e7";
    deps = [ ];
  };

  linux-raw-sys = fetchCrate {
    name = "linux-raw-sys";
    version = "0.4.12";
    sha256 = "c4cd1a83af159aa67994778be9070f0ae1bd732942279cabb14f86f986a21456";
    deps = [ ];
  };

  lock_api = fetchCrate {
    name = "lock_api";
    version = "0.4.11";
    sha256 = "3c168f8615b12bc01f9c17e2eb0cc07dcae1940121185446edc3744920e8ef45";
    deps = [ autocfg scopeguard ];
  };

  log = fetchCrate {
    name = "log";
    version = "0.4.20";
    sha256 = "b5e6163cb8c49088c2c36f57875e58ccd8c87c7427f7fbd50ea6710b2f3f2e8f";
    deps = [ ];
  };

  memchr = fetchCrate {
    name = "memchr";
    version = "2.7.1";
    sha256 = "523dc4f511e55ab87b694dc30d0f820d60906ef06413f93d4d7a1385599cc149";
    deps = [ ];
  };

  memoffset = fetchCrate {
    name = "memoffset";
    version = "0.9.0";
    sha256 = "5a634b1c61a95585bd15607c6ab0c4e5b226e695ff2800ba0cdccddf208c406c";
    deps = [ autocfg ];
  };

  minimal-lexical = fetchCrate {
    name = "minimal-lexical";
    version = "0.2.1";
    sha256 = "68354c5c6bd36d73ff3feceb05efa59b6acb7626617f4962be322a825e61f79a";
    deps = [ ];
  };

  miniz_oxide = fetchCrate {
    name = "miniz_oxide";
    version = "0.7.1";
    sha256 = "e7810e0be55b428ada41041c41f32c9f1a42817901b4ccf45fa3d4b6561e74c7";
    deps = [ adler ];
  };

  mio = fetchCrate {
    name = "mio";
    version = "0.8.10";
    sha256 = "8f3d0b296e374a4e6f3c7b0a1f5a51d748a0d34c85e7dc48fc3fa9a87657fe09";
    deps = [ libc wasi windows-sys ];
  };

  nom = fetchCrate {
    name = "nom";
    version = "7.1.3";
    sha256 = "d273983c5a657a70a3e8f2a01329822f3b8c8172b73826411a55751e404a0a4a";
    deps = [ memchr minimal-lexical ];
  };

  num-integer = fetchCrate {
    name = "num-integer";
    version = "0.1.45";
    sha256 = "225d3389fb3509a24c93f5c29eb6bde2586b98d9f016636dff58d7c6f7569cd9";
    deps = [ autocfg num-traits ];
  };

  num-traits = fetchCrate {
    name = "num-traits";
    version = "0.2.17";
    sha256 = "39e3200413f237f41ab11ad6d161bc7239c84dcb631773ccd7de3dfe4b5c267c";
    deps = [ autocfg ];
  };

  num_cpus = fetchCrate {
    name = "num_cpus";
    version = "1.16.0";
    sha256 = "4161fcb6d602d4d2081af7c3a45852d875a03dd337a6bfdd6e06407b61342a43";
    deps = [ hermit-abi libc ];
  };

  object = fetchCrate {
    name = "object";
    version = "0.32.2";
    sha256 = "a6a622008b6e321afc04970976f62ee297fdbaa6f95318ca343e3eebb9648441";
    deps = [ memchr ];
  };

  once_cell = fetchCrate {
    name = "once_cell";
    version = "1.19.0";
    sha256 = "3fdb12b2476b595f9358c5161aa467c2438859caa136dec86c26fdd2efe17b92";
    deps = [ ];
  };

  parking_lot = fetchCrate {
    name = "parking_lot";
    version = "0.12.1";
    sha256 = "3742b2c103b9f06bc9fff0a37ff4912935851bee6d36f3c02bcc755bcfec228f";
    deps = [ lock_api parking_lot_core ];
  };

  parking_lot_core = fetchCrate {
    name = "parking_lot_core";
    version = "0.9.9";
    sha256 = "4c42a9226546d68acdd9c0a280d17ce19bfe27a46bf68784e4066115788d008e";
    deps = [ cfg-if libc redox_syscall smallvec windows-targets ];
  };

  percent-encoding = fetchCrate {
    name = "percent-encoding";
    version = "2.3.1";
    sha256 = "e3148f5046208a5d56bcfc03053e3ca6334e51da8dfb19b6cdc8b306fae3283e";
    deps = [ ];
  };

  pin-project-lite = fetchCrate {
    name = "pin-project-lite";
    version = "0.2.13";
    sha256 = "8afb450f006bf6385ca15ef45d71d2288452bc3683ce2e2cacc0d18e4be60b58";
    deps = [ ];
  };

  pin-utils = fetchCrate {
    name = "pin-utils";
    version = "0.1.0";
    sha256 = "8b870d8c151b6f2fb93e84a13146138f05d02ed11c7e7c54f8826aaaf7c9f184";
    deps = [ ];
  };

  pkg-config = fetchCrate {
    name = "pkg-config";
    version = "0.3.28";
    sha256 = "69d3587f8a9e599cc7ec2c00e331f71c4e69a5f9a4b8a6efd5b07466b9736f9a";
    deps = [ ];
  };

  powerfmt = fetchCrate {
    name = "powerfmt";
    version = "0.2.0";
    sha256 = "439ee305def115ba05938db6eb1644ff94165c5ab5e9420d1c1bcedbba909391";
    deps = [ ];
  };

  ppv-lite86 = fetchCrate {
    name = "ppv-lite86";
    version = "0.2.17";
    sha256 = "5b40af805b3121feab8a3c29f04d8ad262fa8e0561883e7653e024ae4479e6de";
    deps = [ ];
  };

  proc-macro2 = fetchCrate {
    name = "proc-macro2";
    version = "1.0.76";
    sha256 = "95fc56cda0b5c3325f5fbbd7ff9fda9e02bb00bb3dac51252d2f1bfa1cb8cc8c";
    deps = [ unicode-ident ];
  };

  prost = fetchCrate {
    name = "prost";
    version = "0.12.3";
    sha256 = "146c289cda302b98a28d40c8b3b90498d6e526dd24ac2ecea73e4e491685b94a";
    deps = [ bytes prost-derive ];
  };

  prost-derive = fetchCrate {
    name = "prost-derive";
    version = "0.12.3";
    sha256 = "efb6c9a1dd1def8e2124d17e83a20af56f1570d6c2d2bd9e266ccb768df3840e";
    deps = [ anyhow itertools proc-macro2 quote syn ];
  };

  quote = fetchCrate {
    name = "quote";
    version = "1.0.35";
    sha256 = "291ec9ab5efd934aaf503a6466c5d5251535d108ee747472c3977cc5acc868ef";
    deps = [ proc-macro2 ];
  };

  rand = fetchCrate {
    name = "rand";
    version = "0.8.5";
    sha256 = "34af8d1a0e25924bc5b7c43c079c942339d8f0a8b57c39049bef581b46327404";
    deps = [ rand_core ];
  };

  rand_chacha = fetchCrate {
    name = "rand_chacha";
    version = "0.3.1";
    sha256 = "e6c10a63a0fa32252be49d21e7709d4d4baf8d231c2dbce1eaa8141b9b127d88";
    deps = [ ppv-lite86 rand_core ];
  };

  rand_core = fetchCrate {
    name = "rand_core";
    version = "0.6.4";
    sha256 = "ec0be4795e2f6a28069bec0b5ff3e2ac9bafc99e6a9a7dc3547996c5c816922c";
    deps = [ ];
  };

  redox_syscall = fetchCrate {
    name = "redox_syscall";
    version = "0.4.1";
    sha256 = "4722d768eff46b75989dd134e5c353f0d6296e5aaa3132e776cbdb56be7731aa";
    deps = [ bitflags_1 ];
  };

  regex = fetchCrate {
    name = "regex";
    version = "1.10.2";
    sha256 = "380b951a9c5e80ddfd6136919eef32310721aa4aacd4889a8d39124b026ab343";
    deps = [ regex-automata regex-syntax ];
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

  rustc-demangle = fetchCrate {
    name = "rustc-demangle";
    version = "0.1.23";
    sha256 = "d626bb9dae77e28219937af045c257c28bfd3f69333c512553507f5f9798cb76";
    deps = [ ];
  };

  rustc_version = fetchCrate {
    name = "rustc_version";
    version = "0.4.0";
    sha256 = "bfa0f585226d2e68097d4f95d113b15b83a82e819ab25717ec0590d9584ef366";
    deps = [ semver ];
  };

  rustix = fetchCrate {
    name = "rustix";
    version = "0.38.28";
    sha256 = "72e572a5e8ca657d7366229cdde4bd14c4eb5499a9573d4d366fe1b599daa316";
    deps = [ bitflags errno libc linux-raw-sys windows-sys ];
  };

  ryu = fetchCrate {
    name = "ryu";
    version = "1.0.16";
    sha256 = "f98d2aa92eebf49b69786be48e4477826b256916e84a57ff2a4f21923b48eb4c";
    deps = [ ];
  };

  scopeguard = fetchCrate {
    name = "scopeguard";
    version = "1.2.0";
    sha256 = "94143f37725109f92c262ed2cf5e59bce7498c01bcc1502d7b9afe439a4e9f49";
    deps = [ ];
  };

  semver = fetchCrate {
    name = "semver";
    version = "1.0.21";
    sha256 = "b97ed7a9823b74f99c7742f5336af7be5ecd3eeafcb1507d1fa93347b1d589b0";
    deps = [ ];
  };

  serde = fetchCrate {
    name = "serde";
    version = "1.0.195";
    sha256 = "63261df402c67811e9ac6def069e4786148c4563f4b50fd4bf30aa370d626b02";
    deps = [ serde_derive ];
  };

  serde_derive = fetchCrate {
    name = "serde_derive";
    version = "1.0.195";
    sha256 = "46fe8f8603d81ba86327b23a2e9cdf49e1255fb94a4c5f297f6ee0547178ea2c";
    deps = [ proc-macro2 quote syn ];
  };

  serde_json = fetchCrate {
    name = "serde_json";
    version = "1.0.111";
    sha256 = "176e46fa42316f18edd598015a5166857fc835ec732f5215eac6b7bdbf0a84f4";
    deps = [ itoa ryu serde ];
  };

  serde_spanned = fetchCrate {
    name = "serde_spanned";
    version = "0.6.5";
    sha256 = "eb3622f419d1296904700073ea6cc23ad690adbd66f13ea683df73298736f0c1";
    deps = [ ];
  };

  sha2 = fetchCrate {
    name = "sha2";
    version = "0.10.8";
    sha256 = "793db75ad2bcafc3ffa7c68b215fee268f537982cd901d132f89c6343f3a3dc8";
    deps = [ cfg-if cpufeatures digest ];
  };

  slab = fetchCrate {
    name = "slab";
    version = "0.4.9";
    sha256 = "8f92a496fb766b417c996b9c5e57daf2f7ad3b0bebe1ccfca4856390e3d3bb67";
    deps = [ autocfg ];
  };

  smallvec = fetchCrate {
    name = "smallvec";
    version = "1.11.2";
    sha256 = "4dccd0940a2dcdf68d092b8cbab7dc0ad8fa938bf95787e1b916b0e3d0e8e970";
    deps = [ ];
  };

  socket2 = fetchCrate {
    name = "socket2";
    version = "0.5.5";
    sha256 = "7b5fac59a5cb5dd637972e5fca70daf0523c9067fcdc4842f053dae04a18f8e9";
    deps = [ libc windows-sys ];
  };

  strsim = fetchCrate {
    name = "strsim";
    version = "0.11.0";
    sha256 = "5ee073c9e4cd00e28217186dbe12796d692868f432bf2e97ee73bed0c56dfa01";
    deps = [ ];
  };

  syn = fetchCrate {
    name = "syn";
    version = "2.0.48";
    sha256 = "0f3531638e407dfc0814761abb7c00a5b54992b849452a0646b7f65c9f770f3f";
    deps = [ proc-macro2 unicode-ident ];
  };

  tempfile = fetchCrate {
    name = "tempfile";
    version = "3.9.0";
    sha256 = "01ce4141aa927a6d1bd34a041795abd0db1cccba5d5f24b009f694bdf3a1f3fa";
    deps = [ cfg-if fastrand redox_syscall rustix windows-sys ];
  };

  termcolor = fetchCrate {
    name = "termcolor";
    version = "1.4.0";
    sha256 = "ff1bc3d3f05aff0403e8ac0d92ced918ec05b666a43f83297ccef5bea8a3d449";
    deps = [ winapi-util ];
  };

  textwrap = fetchCrate {
    name = "textwrap";
    version = "0.16.0";
    sha256 = "222a222a5bfe1bba4a77b45ec488a741b3cb8872e5e499451fd7d0129c9c7c3d";
    deps = [ ];
  };

  thiserror = fetchCrate {
    name = "thiserror";
    version = "1.0.56";
    sha256 = "d54378c645627613241d077a3a79db965db602882668f9136ac42af9ecb730ad";
    deps = [ thiserror-impl ];
  };

  thiserror-impl = fetchCrate {
    name = "thiserror-impl";
    version = "1.0.56";
    sha256 = "fa0faa943b50f3db30a20aa7e265dbc66076993efed8463e8de414e5d06d3471";
    deps = [ proc-macro2 quote syn ];
  };

  time = fetchCrate {
    name = "time";
    version = "0.3.31";
    sha256 = "f657ba42c3f86e7680e53c8cd3af8abbe56b5491790b46e22e19c0d57463583e";
    deps = [ deranged powerfmt time-core ];
  };

  time-core = fetchCrate {
    name = "time-core";
    version = "0.1.2";
    sha256 = "ef927ca75afb808a4d64dd374f00a2adf8d0fcff8e7b184af886c3c87ec4a3f3";
    deps = [ ];
  };

  tinyvec = fetchCrate {
    name = "tinyvec";
    version = "1.6.0";
    sha256 = "87cc5ceb3875bb20c2890005a4e226a4651264a5c75edb2421b52861a0a0cb50";
    deps = [ ];
  };

  tokio = fetchCrate {
    name = "tokio";
    version = "1.35.1";
    sha256 = "c89b4efa943be685f629b149f53829423f8f5531ea21249408e8e2f8671ec104";
    deps = [ backtrace pin-project-lite ];
  };

  tokio-util = fetchCrate {
    name = "tokio-util";
    version = "0.7.10";
    sha256 = "5419f34732d9eb6ee4c3578b7989078579b7f039cbbb9ca2c4da015749371e15";
    deps = [ bytes futures-core futures-sink pin-project-lite tokio ];
  };

  toml = fetchCrate {
    name = "toml";
    version = "0.8.8";
    sha256 = "a1a195ec8c9da26928f773888e0742ca3ca1040c6cd859c919c9f59c1954ab35";
    deps = [ serde serde_spanned toml_datetime ];
  };

  toml_datetime = fetchCrate {
    name = "toml_datetime";
    version = "0.6.5";
    sha256 = "3550f4e9685620ac18a50ed434eb3aec30db8ba93b0287467bca5826ea25baf1";
    deps = [ ];
  };

  tracing = fetchCrate {
    name = "tracing";
    version = "0.1.40";
    sha256 = "c3523ab5a71916ccf420eebdf5521fcef02141234bbc0b8a49f2fdc4544364ef";
    deps = [ pin-project-lite tracing-core ];
  };

  tracing-core = fetchCrate {
    name = "tracing-core";
    version = "0.1.32";
    sha256 = "c06d3da6113f116aaee68e4d601191614c9053067f9ab7f6edbcb161237daa54";
    deps = [ ];
  };

  typenum = fetchCrate {
    name = "typenum";
    version = "1.17.0";
    sha256 = "42ff0bf0c66b8238c6f3b578df37d0b7848e55df8577b3f74f92a69acceeb825";
    deps = [ ];
  };

  unicode-bidi = fetchCrate {
    name = "unicode-bidi";
    version = "0.3.14";
    sha256 = "6f2528f27a9eb2b21e69c95319b30bd0efd85d09c379741b0f78ea1d86be2416";
    deps = [ ];
  };

  unicode-ident = fetchCrate {
    name = "unicode-ident";
    version = "1.0.12";
    sha256 = "3354b9ac3fae1ff6755cb6db53683adb661634f67557942dea4facebec0fee4b";
    deps = [ ];
  };

  unicode-normalization = fetchCrate {
    name = "unicode-normalization";
    version = "0.1.22";
    sha256 = "5c5713f0fc4b5db668a2ac63cdb7bb4469d8c9fed047b1d0292cc7b0ce2ba921";
    deps = [ tinyvec ];
  };

  unicode-width = fetchCrate {
    name = "unicode-width";
    version = "0.1.11";
    sha256 = "e51733f11c9c4f72aa0c160008246859e340b00807569a0da0e7a1079b27ba85";
    deps = [ ];
  };

  unicode-xid = fetchCrate {
    name = "unicode-xid";
    version = "0.2.4";
    sha256 = "f962df74c8c05a667b5ee8bcf162993134c104e96440b663c8daa176dc772d8c";
    deps = [ ];
  };

  url = fetchCrate {
    name = "url";
    version = "2.5.0";
    sha256 = "31e6302e3bb753d46e83516cae55ae196fc0c309407cf11ab35cc51a4c2a4633";
    deps = [ form_urlencoded idna percent-encoding ];
  };

  uuid = fetchCrate {
    name = "uuid";
    version = "1.6.1";
    sha256 = "5e395fcf16a7a3d8127ec99782007af141946b4795001f876d54fb0d55978560";
    deps = [ ];
  };

  version_check = fetchCrate {
    name = "version_check";
    version = "0.9.4";
    sha256 = "49874b5167b65d7193b8aba1567f5c7d93d001cafc34600cee003eda787e483f";
    deps = [ ];
  };

  wasi = fetchCrate {
    name = "wasi";
    version = "0.11.0+wasi-snapshot-preview1";
    sha256 = "9c8d87e72b64a3b4db28d11ce29237c246188f4f51057d65a7eab63b7987e423";
    deps = [ ];
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

  winapi-util = fetchCrate {
    name = "winapi-util";
    version = "0.1.6";
    sha256 = "f29e6f9198ba0d26b4c9f07dbe6f9ed633e1f3d5b8b414090084349e46a52596";
    deps = [ winapi ];
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

  zerocopy = fetchCrate {
    name = "zerocopy";
    version = "0.7.32";
    sha256 = "74d4d3961e53fa4c9a25a8637fc2bfaf2595b3d3ae34875568a5cf64787716be";
    deps = [ zerocopy-derive ];
  };

  zerocopy-derive = fetchCrate {
    name = "zerocopy-derive";
    version = "0.7.32";
    sha256 = "9ce1b18ccd8e73a9321186f97e46f9f04b778851177567b1975109d26a08d2a6";
    deps = [ proc-macro2 quote syn ];
  };
}
