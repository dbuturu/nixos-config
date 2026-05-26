{ pkgs, pkgs-unstable, config, inputs, ...}:

let
  # Self-referencing: access our own config to generate a help script
  keybinds = config.wayland.windowManager.hyprland.settings.bind;

  # Function to format each keybinding line for display
  format-keybind = bind:
    let
      # Split the line by comma, e.g., "$mainMod, RETURN, exec, wezterm"
      parts = pkgs.lib.splitString "," bind;
      # Get the keys (first 2 parts), e.g., "$mainMod, RETURN"
      keys = pkgs.lib.concatStringsSep "," (pkgs.lib.take 2 parts);
      # Get the action (the rest), e.g., "exec, wezterm"
      action = pkgs.lib.concatStringsSep "," (pkgs.lib.drop 2 parts);
    in
    # Replace variables and format for readability
    "<b>${pkgs.lib.replaceStrings [ "$mainMod" ] [ "SUPER" ] keys}</b>: ${action}";

  # Create the final list of formatted keybindings
  formatted-keybinds = pkgs.lib.map format-keybind keybinds;

  # writeShellScriptBin creates an executable script in your PATH
  keybinds-script = pkgs.writeShellScriptBin "hypr-keybinds" ''
    echo -e "${pkgs.lib.concatStringsSep "\\n" formatted-keybinds}" | wofi --show dmenu --allow-markup -p "Hyprland Keybindings"
  '';

in # This is the end of the 'let' block and the start of your main config

{
    # Hyprland window manager configuration
    # This is the single source of truth for Hyprland version and settings
    wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs-unstable.hyprland; # Use unstable (0.52+) for crash fixes
    plugins = [
      # pkgs-unstable.hyprlandPlugins.hy3
    ];
    settings = {
      monitor = ",preferred,auto,1";

      # Environment variables to ensure applications detect dark mode
      env = [
        "GTK_THEME,Adwaita:dark"
        "QT_STYLE_OVERRIDE,Adwaita-dark"
        "COLOR_SCHEME,prefer-dark"
        "GTK_APPLICATION_PREFER_DARK_THEME,1"
        # Enable Wayland support for Electron-based apps
        "ELECTRON_ENABLE_WAYLAND,1"
        # Ensure session type advertises Wayland where sessions don't set it
        "XDG_SESSION_TYPE,wayland"
      ];

      exec-once = [ 
        "waybar"
        "swww-daemon"  # Initialize swww daemon
        "blend-wallpaper"  # Set random wallpaper at startup
        "wl-paste --type text --watch cliphist store"  # Start clipboard history daemon
        "wl-paste --type image --watch cliphist store"  # Store image clipboard items
        "gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'"  # Set GTK dark theme
        "gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'"  # Set color scheme preference
      ];

      "$mainMod" = "SUPER";
      
      bind = [
        # -- App Launchers --
        "$mainMod, RETURN, exec, wezterm"
        # "$mainMod SHIFT, RETURN, exec, wezterm"
        "$mainMod, D, exec, wofi --show drun"
        # "$mainMod, D, exec, paswordmanger"        
        "$mainMod, N, exec, obsidian"
        "$mainMod, W, exec, firefox"
        "$mainMod, Escape, exec, hyprlock"
        "$mainMod, R, exec, wezterm yazi"
        "$mainMod SHIFT, R, exec, wezterm btop"
        "$mainMod, E, exec, wezterm neomutt"
        "$mainMod SHIFT, E, exec, wezterm abook"
        "$mainMod, M, exec, wezterm ncmpcpp"
        "$mainMod SHIFT, N, exec, wezterm newsboat"
        "$mainMod SHIFT, W, exec, wezterm nmtui"
        "$mainMod, BACKSPACE, exec, wlogout"
         
        # -- Function Keys --
        "$mainMod, F1, exec, hypr-keybinds"
        "$mainMod, F4, exec, wezterm pulsemixer"
        "$mainMod, F8, exec, wezterm mutt-wizard"
        # "$mainMod, F9, exec, dmenumount"
        # "$mainMod, F10, exec, dmenuumount"
        "$mainMod, F11, exec, mpv av://v4l2:/dev/video0 --profile=low-latency --untimed"
        "$mainMod, apostrophe, exec, wofi-emoji"
        "$mainMod, Insert, exec, cliphist list | wofi --dmenu | cliphist decode | wl-copy"

        # -- Screenshots --
        ", Print, exec, screenshot full"
        "SHIFT, Print, exec, screenshot select"

        # -- Screencasting & Recording --
        # "$mainMod, Print, exec, dmenurecord"
        # "$mainMod SHIFT, C, exec, toggle-webcam"
        # "$mainMod, Scroll_Lock, exec, toggle-screenkey"

        # -- Window Management --
        "$mainMod, Q, killactive"
        # "$mainMod, DELETE, exec, kill-recording # Kills any running screen recording"
        "$mainMod, F, fullscreen"
        "$mainMod, SPACE, togglefloating"
        # "$mainMod, P, pseudo, # dwindle"
        # "$mainMod SHIFT, P, togglesplit, # dwindle"

        # -- Hy3 Layout --
        # "$mainMod, S, hy3:makegroup, v"
        # "$mainMod, G, hy3:makegroup, h"
        # "$mainMod, Z, hy3:makegroup, tab"

        # -- Focus / Move with Vim Keys --
        "$mainMod, h, movefocus, l"
        "$mainMod, l, movefocus, r"
        "$mainMod, k, movefocus, u"
        "$mainMod, j, movefocus, d"

        # -- Move with Vim Keys --
        "$mainMod SHIFT, h, movewindow, l"
        "$mainMod SHIFT, l, movewindow, r"
        "$mainMod SHIFT, k, movewindow, u"
        "$mainMod SHIFT, j, movewindow, d"

        # -- Resize Windows --	
        #"$mainMod CTRL, left, resizeactive, -20 0"
        #"$mainMod CTRL, right, resizeactive, 20 0"
        #"$mainMod CTRL, up, resizeactive, 0 -20"
        #"$mainMod CTRL, down, resizeactive, 0 20"

        # -- Clipboard Manager --
        "$mainMod, V, exec, cliphist list | wofi --dmenu | cliphist decode | wl-copy"

        # -- Scratchpad --
        "$mainMod, S, togglespecialworkspace, magic"
        "$mainMod SHIFT, S, movetoworkspace, special:magic"

        # -- Workspace Navigation --
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"
      ];
      
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        # layout = "hy3";
        allow_tearing = true; # Reduces input lag for gaming
        # Border colors will be set by Catppuccin theme
      };

      decoration = { 
        rounding = 10;
        blur = {
          enabled = true;
          size = 5;
          passes = 2;
        };
        active_opacity = 0.95;
        inactive_opacity = 0.75;
        fullscreen_opacity = 1.00;
      };

      animations = {
        enabled = true; 
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      plugin = {
        hy3 = {
          no_gaps_when_only = 1; # 0 - always show gaps, 1 - hide gaps with a single window
          node_collapse_policy = 2; # 2 = keep the nested group only if its parent is a tab group
          group_inset = 10;
          tab_first_window = false;

          tabs = {
            height = 20;
            padding = 6;
            from_top = false;
            radius = 10;
            render_text = true;
            text_center = true;
            text_font = "Sans";
            text_height = 8;
            text_padding = 3;
          };

          autotile = {
            enable = true;
            ephemeral_groups = true;
            trigger_width = 800;
            trigger_height = 500;
            workspaces = "all";
          };
        };
      };

      # Window rules - automatically assign applications to specific workspaces
      windowrulev2 = [
        "workspace 2,class:^(brave-browser)$"
        "workspace 1,class:^(Godot)$"
        "workspace 1,class:^(godot)$"
        "tile,class:^(Godot)$"
        "tile,class:^(godot)$"
      ];

      input = {
        kb_layout = "jp";
        kb_variant = "";
        kb_model = "jp106";
        kb_options = "caps:escape_shifted_capslock";
        kb_rules = "";

        follow_mouse = 1;

        sensitivity = 0; # -1.0 - 1.0, 0 means no modification.

        touchpad = {
          natural_scroll = false;
        };
      };
    };
  };

  # Add our generated script to user packages and include Wayland helpers
  home.packages = [ keybinds-script pkgs.xdg-desktop-portal pkgs.xdg-desktop-portal-wlr ];

  # Enable Catppuccin theming for Hyprland
  catppuccin.hyprland.enable = true;
}
