{ base }:
base.languages.terraform.mkComponent {
  name = "carboniferous-park";
  src = ./.;
  enableApplyInShell = true;
}
