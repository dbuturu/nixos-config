# home/services.nix
{ pkgs, theme, ... }:

{
  # -- User-level System Services --
  
  # MPRIS proxy forwards D-Bus media control signals to Waybar
  services.mpris-proxy.enable = true;

  # playerctl provides CLI media controls (play, pause, next, etc.)
  home.packages = [ pkgs.playerctl ];

  # Mako is a Wayland notification daemon - replaces dunst on X11
  services.mako = {
    enable = true;
    # Settings go in a nested attrset, not top-level
    settings = {
      "background-color" = "#${theme.primary_background}";
      "text-color"       = "#${theme.primary_foreground}";
      "border-color"     = "#${theme.primary_accent}";
      "border-size"      = 2;
      "border-radius"    = 10;
      "default-timeout"  = 5000;
      "font"             = "JetBrainsMono Nerd Font 12";
    };
  };

  # Systemd user services and timers
  systemd.user.services.dynamic-wallpaper = {
    Unit = {
      Description = "Calculate and update dynamic blended wallpaper via swww";
      After = [ "swww-daemon.service" ];
    };
    Service = {
      Type = "oneshot";
      # Executes the script directly out of your user's dynamic nix package profile
      ExecStart = "blend-wallpaper";
    };
  };

  systemd.user.timers.dynamic-wallpaper = {
    Unit = {
      Description = "Trigger wallpaper blending calculation every 3 minutes";
    };
    Timer = {
      OnCalendar = "*:0/3";
      Persistent = true;
    };
    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
  
  services.wlsunset = {
    enable = true;
    latitude = "-1.09";  # Approximate for Narok
    longitude = "35.86";
    temperature = {
      day = 6500;
      night = 3500;
    };
  };
}
