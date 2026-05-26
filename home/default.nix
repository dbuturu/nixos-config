# default.nix
{ catppuccin, ... }:

{
  imports = [

    # Desktop Environment & Compositor Core
    ./hyprland.nix
    ./waybar.nix
    ./wofi.nix
    ./wlogout.nix
    ./swww/swww.nix
    ./hyprlock/hyprlock.nix

    # Shell, Shell Utilities & Custom Binary Layer
    ./shell.nix
    ./git.nix
    ./direnv.nix
    ./cli-tools.nix
    ./scripts.nix 

    # Applications & Environments
    ./packages.nix
    ./browsers.nix
    ./neovim.nix
    ./wezterm.nix

    # System Integration & Background Workers
    ./environment.nix
    ./default-apps.nix
    ./service.nix
    ./gtk.nix
  ];
}
