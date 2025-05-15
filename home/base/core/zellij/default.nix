let
  shellAliases = {
    "zj" = "zellij";
  };
in {
  programs.zellij = {
    enable = false;
  };
  # only works in bash/zsh, not nushell
  home.shellAliases = shellAliases;
  programs.nushell.shellAliases = shellAliases;
}
