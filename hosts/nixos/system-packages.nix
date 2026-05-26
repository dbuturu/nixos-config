# system-packages.nix - System-wide packages
{ pkgs, pkgs-unstable, ... }:

{
  environment.systemPackages = with pkgs; [
    nfs-utils   # For NFS filesystem support
    cifs-utils  # For SMB/CIFS filesystem support
    openvpn     # OpenVPN client
    wireguard-tools # WireGuard VPN tools
    networkmanagerapplet # GUI for NetworkManager VPN
    podman      # Container runtime
    podman-tui  # Terminal UI for Podman
    podman-compose # Docker Compose compatibility
    ghostscript # Required for CUPS print preview generation
    poppler-utils # PDF conversion tools for print preview
  ];

  # Podman configuration for rootless containers
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true; # Docker compatibility
      defaultNetwork.settings.dns_enabled = true;
    };

    # Waydroid
    waydroid.enable = true;
  };

  # System-wide font configuration for better rendering
  fonts = {
    enableDefaultPackages = true;
    
    # Font optimization settings
    fontconfig = {
      enable = true;
      antialias = true;
      hinting = {
        enable = true;
        style = "slight"; # Better for LCD screens
      };
      subpixel = {
        rgba = "rgb"; # For RGB subpixel layout (most common)
        lcdfilter = "default";
      };
      defaultFonts = {
        monospace = [ "JetBrainsMono Nerd Font" "JetBrains Mono" ];
        sansSerif = [ "Inter" "DejaVu Sans" ];
        serif = [ "DejaVu Serif" ];
      };
    };
    
    packages = with pkgs; [
      inter # Better system font
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      source-han-sans
      source-han-serif
    ];
  };

  programs = {
    zsh.enable = true; # Enable Zsh system-wide
  
    #ssh.startAgent = true;

    # Hyprland window manager (Wayland-based)
    # Note: Package version is managed in home/hyprland.nix via home-manager
    hyprland.enable = true;
    hyprland.portalPackage = pkgs-unstable.xdg-desktop-portal-hyprland;
    hyprland.xwayland.enable = true; # X11 app compatibility
  };
}
