# home/gtk.nix
{ lib, pkgs, ... }:

{
  # 1. Global Pointer Configuration (Fixes XWayland vs Native cursor alignment)
  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    x11.enable = true; # Generates the XWayland / legacy fallback paths
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 24;
  };

  # 2. GTK Theme Configuration
  gtk = {
    enable = true;

    # iconTheme managed by Catppuccin kvantum module

    # (Note: cursorTheme inside gtk is omitted now as home.pointerCursor handles it)

    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra; # Ensures the Adwaita-dark assets are explicitly present
    };

    # Changed from 'true' to 1 to match native GTK configuration specifications
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  # Tell libadwaita applications to prefer the dark theme.
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      "color-scheme" = "prefer-dark";
    };
  };

  # Qt application theming with Catppuccin support
  qt = {
    enable = true;
    platformTheme.name = "kvantum";
    style.name = "kvantum";
  };

  # Enable Catppuccin theming for Qt applications
  catppuccin.kvantum.enable = true;
}
