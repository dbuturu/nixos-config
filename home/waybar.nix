# home/waybar.nix
{ pkgs, pkgs-unstable, ... }:
{
  programs.waybar = {
    enable = true;
    package = pkgs-unstable.waybar;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 36;
        spacing = 4;
        reload_style_on_change = true;
        
        # Swapped "hyprland/workspaces" for "river/tags"
        modules-left = [ "river/tags" "mpris" "custom/music-viz" ];
        # Swapped "hyprland/window" for "river/window"
        modules-center = [ "river/window" ];
        modules-right = [ "custom/services" "custom/vpn" "pulseaudio" "network" "bluetooth" "cpu" "memory" "custom/temps" "battery" "clock" "tray" ];

        # ----------------------------------------------------------------
        # River Specific Monitoring Modules
        # ----------------------------------------------------------------
        "river/tags" = {
          "num-tags" = 9;
        };
        
        "river/window" = {
          "format" = "{}";
          "max-length" = 50;
        };

        # ----------------------------------------------------------------
        # Restored Applications & Metrics Pipeline (Carried over exactly)
        # ----------------------------------------------------------------
        "mpris" = {
          "format" = "{player_icon}";
          "format-paused" = "";
          "format-stopped" = "";
          "player-icons" = {
            "default" = "";
            "mpv" = "🎵";
          };
          "on-click" = "playerctl play-pause";
          "tooltip-format" = "{player}: {title} - {artist}";
        };

        "pulseaudio" = {
          "format" = "{icon} {volume}%";
          "format-muted" = " Muted";
          "format-icons" = {
            "default" = [ "󰕾" "󰕾" "󰕾" ];
          };
          "on-click" = "wezterm -e pulsemixer";
        };

        "network" = {
          "format-wifi" = "ᯤ";
          "format-ethernet" = "󰈀";
          "format-disconnected" = "󰌙";
          "on-click" = "wezterm -e nmtui";
          "tooltip-format" = "{ifname}: {essid} via {gwaddr}";
        };

        "cpu" = {
          "format" = "󰻠 {usage}%";
          "interval" = 5;
          "tooltip" = true;
          "on-click" = "wezterm -e btop";
        };

        "memory" = {
          "format" = "󰍛 {}%";
          "interval" = 10;
          "tooltip" = true;
          "on-click" = "wezterm -e bash -c 'free -h; read'";
        };

        "custom/temps" = {
          "exec" = "waybar-temps";
          "format" = "{}";
          "interval" = 10;
          "tooltip" = true;
          "tooltip-format" = "CPU and GPU Temperatures";
          "on-click" = "wezterm -e bash -c 'sensors; read'";
        };

        "custom/services" = {
          "exec" = "waybar-services";
          "format" = "{}";
          "interval" = 30;
          "tooltip" = true;
          "tooltip-format" = "Service Status (🤖=Ollama)";
          "on-click" = "wezterm -e bash -c 'systemctl --no-pager status ollama; read'";
        };

        "custom/music-viz" = {
          "exec" = "waybar-music-viz";
          "format" = "{}";
          "interval" = 1;
          "tooltip" = false;
          "on-click" = "playerctl play-pause";
          "on-scroll-up" = "playerctl next";
          "on-scroll-down" = "playerctl previous";
        };

        "custom/vpn" = {
          "exec" = "waybar-vpn";
          "format" = "{}";
          "interval" = 5;
          "tooltip" = true;
          "tooltip-format" = "VPN Status - Click to toggle";
          "on-click" = "wezterm -e bash -c 'if nmcli connection show --active | grep -q be-bru.prod.surfshark.comsurfshark_openvpn_udp; then vpn disconnect; else vpn connect; fi; read'";
        };
        
        "clock" = {
          "format" = " {:%H:%M}";
          "tooltip-format" = "<big>{:%A, %d %B %Y}</big>\n<tt><small>{calendar}</small></tt>";
          "calendar" = {
            "mode" = "year";
            "mode-mon-col" = 3;
            "weeks-pos" = "right";
            "on-scroll" = 1;
            "format" = {
              "months" = "<span color='#ffead3'><b>{}</b></span>";
              "days" = "<span color='#ecc6d9'><b>{}</b></span>";
              "weeks" = "<span color='#99ffdd'><b>W{}</b></span>";
              "weekdays" = "<span color='#ffcc66'><b>{}</b></span>";
              "today" = "<span color='#ff6699'><b><u>{}</u></b></span>";
            };
          };
        };

        "battery" = {
          "states" = {
            "good" = 95;
            "warning" = 30;
            "critical" = 15;
          };
          "format" = "{icon} {capacity}%";
          "format-charging" = "󰂄 {capacity}%";
          "format-plugged" = "󰂄 {capacity}%";
          "format-alt" = "{time} {icon}";
          "format-icons" = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
        };

        "bluetooth" = {
          "format" = " {status}";
          "format-connected" = " {device_alias}";
          "format-connected-battery" = " {device_alias} {device_battery_percentage}%";
          "tooltip-format" = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
          "tooltip-format-connected" = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
          "tooltip-format-enumerate-connected" = "{device_alias}\t{device_address}";
          "tooltip-format-enumerate-connected-battery" = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
          "on-click" = "wezterm -e bluetui";
        };

        "tray" = {
          "icon-size" = 16;
          "spacing" = 10;
        };
      };
    };

    # ----------------------------------------------------------------
    # Refined Styling Layer with Native Dynamic Tag-Folding CSS
    # ----------------------------------------------------------------
    style = ''
      @import "catppuccin.css";
      * {
        font-family: "JetBrainsMono Nerd Font", "JetBrains Mono", "Inter", "Noto Sans", sans-serif;
        font-size: 14px;
        font-weight: 500;
        min-height: 0;
        border: none;
      }

      window#waybar {
        background-color: @base;
        color: @text;
        padding: 4px 8px;
      }

      /* Base layout rendering configurations for River tags */
      #tags button {
        padding: 4px 8px;
        margin: 4px 2px;
        background: transparent;
        color: @subtext0;
      }

      /* FIX: Use pure GTK CSS mechanics to securely collapse unused elements */
      #tags button:not(.focused):not(.occupied) {
        margin: 0;
	padding: 0;
	min-width: 0;
	font-size: 0px;
	opacity: 0;
      }
      
      #tags button.focused {
        background: @mauve;
        color: @base;
        border-radius: 4px;
      }

      #tags button:hover {
        background: @surface1;
        color: @text;
        border-radius: 4px;
      }

      #cpu, #memory, #custom-temps, #pulseaudio, 
      #network, #bluetooth, #battery, #clock, #mpris, #custom-services,
      #custom-music-viz, #custom-vpn {
        padding: 4px 10px;
        margin: 4px 3px;
        background: @surface0;
        color: @text;
        border-radius: 4px;
      }

      #custom-temps.critical {
        background: @red;
        color: @base;
        animation: temp-warning 1s ease-in-out infinite alternate;
      }

      @keyframes temp-warning {
        from { opacity: 1; }
        to { opacity: 0.7; }
      }

      #window {
        background: transparent;
        color: @subtext1;
        font-style: italic;
      }

      #tray {
        padding: 4px 10px;
        margin: 4px 3px;
        background: @surface0;
        border-radius: 4px;
      }
    '';
  };

  catppuccin.waybar = {
    enable = true;
    mode = "createLink";
  };
}
