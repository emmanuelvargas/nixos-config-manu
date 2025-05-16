{
  pkgs,
  config,
  lib,
  ...
}: {
  # If your themes for mouse cursor, icons or windows don’t load correctly,
  # try setting them with home.pointerCursor and gtk.theme,
  # which enable a bunch of compatibility options that should make the themes load in all situations.

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 16;
  };

  # set dpi for 4k monitor
  xresources.properties = {
    # # dpi for Xorg's font
    # "Xft.dpi" = 150;
    # # or set a generic dpi
    # "*.dpi" = 150;
  };

  # gtk's theme settings, generate files:
  #   1. ~/.gtkrc-2.0
  #   2. ~/.config/gtk-3.0/settings.ini
  #   3. ~/.config/gtk-4.0/settings.ini
  gtk = {
    enable = true;

    font = {
      name = lib.mkForce "Noto Sans";
      package = pkgs.noto-fonts;
      size = lib.mkForce 11;
    };

    gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";

    iconTheme = {
      name = lib.mkForce "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    theme = {
      # https://github.com/catppuccin/gtk
      name = lib.mkForce "catppuccin-macchiato-pink-compact";
     # package = lib.mkForce pkgs.catppuccin-gtk.override {
     #   # https://github.com/NixOS/nixpkgs/blob/nixos-23.05/pkgs/data/themes/catppuccin-gtk/default.nix
     #   accents = ["pink"];
     #   size = "compact";
     #   variant = "macchiato";
     # };
    };
  };
}
