# sddm.nix - Greetd Display Manager Configuration (Replaces SDDM)
{ config, pkgs, ... }:

let
  # Hyprland session wrapper
  hyprland-session = pkgs.writeShellScriptBin "hyprland-session" ''
    export XDG_SESSION_TYPE=wayland
    export XDG_SESSION_DESKTOP=Hyprland
    export XDG_CURRENT_DESKTOP=Hyprland
    export XKB_DEFAULT_LAYOUT=jp
    export XKB_DEFAULT_MODEL=jp106
    
    # Start Hyprland
    exec ${pkgs.hyprland}/bin/Hyprland
  '';
in
{
  # Disable SDDM
  services.displayManager.sddm.enable = false;

  # Enable Greetd
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        # Use tuigreet (TUI greeter)
        command = "${pkgs.tuigreet}/bin/tuigreet --time --asterisks --remember --cmd ${hyprland-session}/bin/hyprland-session";
        user = "greeter";
      };
    };
  };

}