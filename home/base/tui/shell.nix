{
  config,
  oh-my-zsh,
  pkgs-unstable,
  ...
}: let
  inherit (pkgs-unstable) nu_scripts;
in {
  home.file = {
      ".zshrc" = {
      source = ../../../.zshrc;
    };
  };
  xdg.dataFile = {
    "oh-my-zsh" = {
      source = oh-my-zsh;
    };
      #    "oh-my-zsh-custom" = {
      #      source = ../../../.local/share/oh-my-zsh-custom;
      #    };
  };
  programs.bash = {
    # load the alias file for work
    bashrcExtra = ''
      alias_for_work=/etc/agenix/alias-for-work.bash
      if [ -f $alias_for_work ]; then
        . $alias_for_work
      else
        echo "No alias file found for work"
      fi
    '';
  };
}
