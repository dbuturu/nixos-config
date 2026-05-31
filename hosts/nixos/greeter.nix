# sddm.nix - Greetd Display Manager Configuration (Replaces SDDM)
{ config, pkgs, ... }:

let
  # River session wrapper
  river-session = pkgs.writeShellScriptBin "river-session" ''
    export XDG_SESSION_TYPE=wayland
    export XDG_SESSION_DESKTOP=river
    export XDG_CURRENT_DESKTOP=river
    export XKB_DEFAULT_LAYOUT=jp
    export XKB_DEFAULT_MODEL=jp106
    
    # Start river
    exec systemd-cat -t river ${pkgs.river-classic}/bin/river
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
        command = "${pkgs.tuigreet}/bin/tuigreet --time --asterisks --remember --cmd ${river-session}/bin/river-session";
        user = "greeter";
      };
    };
  };

}
