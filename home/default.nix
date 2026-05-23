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
    ./scripts.nix       # Exports our custom blend-wallpaper binary

    # Applications & Environments
    ./packages.nix
    ./browsers.nix
    ./vscode.nix
    ./neovim.nix
    ./wezterm.nix
    ./1password.nix

    # System Integration & Background Workers
    ./environment.nix
    ./default-apps.nix
    ./service.nix       # References and schedules our custom binary
    ./gtk.nix
  ];
}
