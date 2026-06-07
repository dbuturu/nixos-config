# ./home/wm.nix
#
# River window manager — configured to mirror LukeSmith's DWM layout.
# Layout engine: wideriver (left/right/top/monocle/wide, from nixpkgs)

{ pkgs, ... }:

let
  wideriverPackage = pkgs.wideriver;

  # Nix completely handles the pure store-path shebang generation here!
  riverInit = pkgs.writeShellScriptBin "river-init" ''
    # ----------------------------------------------------------------
    # 0. Variables
    # ----------------------------------------------------------------
    MOD="Mod4"   # Super / Windows key
    TERM="${pkgs.wezterm}/bin/wezterm"
    MENU="${pkgs.wofi}/bin/wofi --show drun --allow-images --prompt 'Run:'"

    # ----------------------------------------------------------------
    # 0a. Wayland environment — export before any portal consumer starts.
    #     Restores the portal fix; without this the file picker times out.
    # ----------------------------------------------------------------
    export XDG_CURRENT_DESKTOP=river
    export XDG_SESSION_TYPE=wayland
    # Force Firefox and Electron apps into native Wayland mode.
    # Without these they fall back to XWayland and mishandle text-input,
    # producing the "inactive text input tried to commit" River warning.
    export MOZ_ENABLE_WAYLAND=1
    export NIXOS_OZONE_WAYLAND=1

    dbus-update-activation-environment --systemd \
      DISPLAY             \
      WAYLAND_DISPLAY     \
      XDG_CURRENT_DESKTOP \
      XDG_SESSION_TYPE    \
      MOZ_ENABLE_WAYLAND  \
      NIXOS_OZONE_WAYLAND

    # ----------------------------------------------------------------
    # 1. Tags 1–9 + Special Layout Rules
    # ----------------------------------------------------------------
    for i in $(seq 1 9);
    do
      tags=$((1 << ($i - 1)))
      riverctl map normal $MOD               $i  set-focused-tags    $tags &
      riverctl map normal $MOD+Shift         $i  set-view-tags       $tags &
      riverctl map normal $MOD+Control       $i  toggle-focused-tags $tags &
      riverctl map normal $MOD+Shift+Control $i  toggle-view-tags    $tags &
    done

    all_tags=$(( (1 << 32) - 1 ))
    riverctl map normal $MOD       0  set-focused-tags  $all_tags &
    riverctl map normal $MOD+Shift 0  set-view-tags     $all_tags &

    # ----------------------------------------------------------------
    # 2. Application Launchers (Migrated from Hyprland)
    # ----------------------------------------------------------------
    riverctl map normal $MOD         Return  spawn "$TERM" &
    riverctl map normal $MOD         d       spawn "$MENU" &
    riverctl map normal $MOD         q       close &
    # riverctl map normal $MOD+Shift q       exit &

    # Core Workspace Applications
    riverctl map normal $MOD       w       spawn "firefox" &
    riverctl map normal $MOD       n       spawn "obsidian" &
    riverctl map normal $MOD       Escape  spawn "${pkgs.hyprlock}/bin/hyprlock" &
    riverctl map normal $MOD       BackSpace spawn "${pkgs.wlogout}/bin/wlogout" &

    # Embedded Terminal TUI Utilities
    riverctl map normal $MOD       r       spawn "$TERM -e yazi" &
    riverctl map normal $MOD+Shift r       spawn "$TERM -e btop" &
    riverctl map normal $MOD       e       spawn "$TERM -e neomutt" &
    riverctl map normal $MOD+Shift e       spawn "$TERM -e abook" &
    riverctl map normal $MOD       m       spawn "$TERM -e ncmpcpp" &
    riverctl map normal $MOD+Shift n       spawn "$TERM -e newsboat" &
    riverctl map normal $MOD+Shift w       spawn "$TERM -e nmtui" &

    # ----------------------------------------------------------------
    # 3. Functional hotkeys & Overlays
    # ----------------------------------------------------------------
    riverctl map normal $MOD       F4      spawn "$TERM -e pulsemixer" &
    riverctl map normal $MOD       F8      spawn "$TERM -e mutt-wizard" &
    riverctl map normal $MOD       @       spawn "${pkgs.wofi-emoji}/bin/wofi-emoji" &

    # Low-latency webcam monitor wrapper
    riverctl map normal $MOD       F11     spawn "${pkgs.mpv}/bin/mpv av://v4l2:/dev/video0 --profile=low-latency --untimed" &

    # Clipboard manager pipelines via Wofi
    riverctl map normal $MOD       Insert  spawn "cliphist list | ${pkgs.wofi}/bin/wofi --dmenu | cliphist decode | wl-copy" &
    riverctl map normal $MOD       v       spawn "cliphist list | ${pkgs.wofi}/bin/wofi --dmenu | cliphist decode | wl-copy" &

    # ----------------------------------------------------------------
    # 4. Scratchpad Mechanics (The 32nd Tag Strategy)
    # ----------------------------------------------------------------
    SCRATCHPAD_MASK=$((1 << 31))
    riverctl map normal $MOD       s       toggle-focused-tags $SCRATCHPAD_MASK &
    riverctl map normal $MOD+Shift s       toggle-view-tags    $SCRATCHPAD_MASK &

    # ----------------------------------------------------------------
    # 5. Stack Focus & Navigation Directional Layer
    # ----------------------------------------------------------------
    riverctl map normal $MOD       j  focus-view next &
    riverctl map normal $MOD       k  focus-view previous &
    riverctl map normal $MOD+Shift j  swap next &
    riverctl map normal $MOD+Shift k  swap previous &

    # Master area promotion trigger
    riverctl map normal $MOD+Shift Return  zoom &

    # Directional spatial navigation controls
    riverctl map normal $MOD       Left   focus-view left &
    riverctl map normal $MOD       Right  focus-view right &
    riverctl map normal $MOD       Up     focus-view up &
    riverctl map normal $MOD       Down   focus-view down &
    riverctl map normal $MOD+Shift Left   swap left &
    riverctl map normal $MOD+Shift Right  swap right &
    riverctl map normal $MOD+Shift Up     swap up &
    riverctl map normal $MOD+Shift Down   swap down &

    # ----------------------------------------------------------------
    # 6. Layout Scaling & Geometry Rules
    # ----------------------------------------------------------------
    riverctl map normal $MOD       h  send-layout-cmd wideriver "--ratio -0.05" &
    riverctl map normal $MOD       l  send-layout-cmd wideriver "--ratio +0.05" &
    riverctl map normal $MOD+Shift h  send-layout-cmd wideriver "--count +1" &
    riverctl map normal $MOD+Shift l  send-layout-cmd wideriver "--count -1" &

    # Window State Triggers
    riverctl map normal $MOD       f            toggle-fullscreen &
    riverctl map normal $MOD+Shift Space        toggle-float &

    # Dynamic layout engine selectors
    riverctl map normal $MOD         Space      send-layout-cmd wideriver "--layout-toggle" &
    riverctl map normal $MOD+Control m          send-layout-cmd wideriver "--layout monocle" &
    riverctl map normal $MOD+Control r          send-layout-cmd wideriver "--layout right" &
    riverctl map normal $MOD+Control t          send-layout-cmd wideriver "--layout top" &
    riverctl map normal $MOD+Control b          send-layout-cmd wideriver "--layout bottom" &
    riverctl map normal $MOD+Control w          send-layout-cmd wideriver "--layout wide" &

    # ----------------------------------------------------------------
    # 7. Multi-Monitor Profiles
    # ----------------------------------------------------------------
    riverctl map normal $MOD       period  focus-output  next &
    riverctl map normal $MOD       comma   focus-output  previous &
    riverctl map normal $MOD+Shift period  send-to-output next &
    riverctl map normal $MOD+Shift comma   send-to-output previous &

    # ----------------------------------------------------------------
    # 8. Pointer Actions
    # ----------------------------------------------------------------
    riverctl map-pointer normal $MOD BTN_LEFT   move-view &
    riverctl map-pointer normal $MOD BTN_RIGHT  resize-view &
    riverctl map-pointer normal $MOD BTN_MIDDLE toggle-float &

    # ----------------------------------------------------------------
    # 9. Hardware & Media Controls
    # ----------------------------------------------------------------
    riverctl map normal None XF86AudioRaiseVolume   spawn "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+" &
    riverctl map normal None XF86AudioLowerVolume   spawn "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-" &
    riverctl map normal None XF86AudioMute          spawn "wpctl set-mute   @DEFAULT_AUDIO_SINK@ toggle" &
    riverctl map normal None XF86AudioMicMute       spawn "wpctl set-mute   @DEFAULT_AUDIO_SOURCE@ toggle" &
    riverctl map normal None XF86MonBrightnessUp    spawn "${pkgs.brightnessctl}/bin/brightnessctl set 5%+" &
    riverctl map normal None XF86MonBrightnessDown  spawn "${pkgs.brightnessctl}/bin/brightnessctl set 5%-" &

    # Screenshots
    riverctl map normal None Print  spawn screenshot full &
    riverctl map normal Shift Print spawn screenshot select &


    # ----------------------------------------------------------------
    # 10. Wait for all riverctl jobs, then start daemons
    #
    #     Every riverctl call above is backgrounded (&) so they all run
    #     concurrently instead of sequentially.  'wait' here blocks until
    #     the last one finishes before River's layout engine and daemons
    #     start — preserving correct startup order at no extra cost.
    # ----------------------------------------------------------------
    wait

      waybar &
      swww-daemon &
      blend-wallpaper &
      wl-paste --type text --watch cliphist store &
      wl-paste --type image --watch cliphist store &
      gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark' &
      gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' &
      # wideriver layout provider startup execution parameters
      riverctl default-layout wideriver
      ${wideriverPackage}/bin/wideriver \
        --layout                       left \
	--layout-alt                   monocle \
	--stack                        dwindle \
	--count-master                 1 \
	--ratio-master                 0.50 \
	--inner-gaps                   4 \
	--outer-gaps                   4 \
	--smart-gaps \
	--border-width                 2 \
	--border-width-monocle         0 \
	--border-color-focused         "0x005577" \
	--border-color-unfocused       "0x444444" \
	--border-color-focused-monocle "0x005577" \
	--log-threshold                WARNING &
  '';
in {
  home.packages = with pkgs; [
    river-classic
    riverInit
    wideriverPackage
    xdg-desktop-portal xdg-desktop-portal-wlr
    # NOTE: brightnessctl cliphist blend-wallpaper grim mpv slurp swww wofi wl-clipboard wlogout wezterm are install and managed is other files.
  ];

  # Deploys your generated nix executable script directly to River's initialization path
  xdg.configFile."river/init" = {
    executable = true;
    text = ''
      #!/usr/bin/env sh
      exec ${riverInit}/bin/river-init
    '';
  };
}
