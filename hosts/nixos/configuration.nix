# configuration.nix
{
  inputs,
  config,
  pkgs,
  pkgs-unstable,
  theme,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix # Auto-generated hardware config
    ./system-packages.nix # System-wide packages
    ./home.nix # Home-manager configuration
    ./greeter.nix # Greetd Display Manager Configuration
    ./portal.nix
  ];

  # Bootloader - systemd-boot is simpler than GRUB
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # Networking
  networking = {
    hostName = "nixos";
    networkmanager.enable = true; # GUI network management
    networkmanager.plugins = with pkgs; [
      networkmanager-openvpn
      networkmanager-openconnect
    ];

    # Disable IPv6 to prevent VPN leaks
    enableIPv6 = false;

    # Firewall configuration for Minecraft server
    firewall = {
      enable = true;
      allowedTCPPorts = [ 25565 ]; # Minecraft server
      allowedUDPPorts = [ 25565 ]; # Minecraft server
    };
  };

  services = {
    dbus.enable = true;

    # DNS resolution service for caching and security
    resolved = {
      enable = true;
      settings.Resolve = {
        DNS = "45.90.28.0#29a6c7.dns.nextdns.io 45.90.30.0#29a6c7.dns.nextdns.io";
      };
    };

    # Enable network printer discovery
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    #Configure keymap in X11
    xserver.xkb = {
      layout = "jp";
      variant = "OADG109A";
    };

    # Enable NVIDIA driver loading
    xserver.videoDrivers = [ "nvidia" ];
    xserver.screenSection = ''
      Option "Coolbits" "28"
    '';

    # Enable UPower for power management information
    upower.enable = true;

    # Fix NVIDIA device node creation
    udev.extraRules = ''
      KERNEL=="nvidia_uvm", OWNER="root", GROUP="video", MODE="0660"
      KERNEL=="nvidia*", OWNER="root", GROUP="video", MODE="0660"
      KERNEL=="nvidiactl", OWNER="root", GROUP="video", MODE="0660"
    '';

    # Printing services - CUPS with Brother printer support
    printing = {
      enable = true;
      drivers = with pkgs; [
        brlaser # Brother laser printer driver (open source)
        brgenml1lpr # Brother generic LPR driver
        brgenml1cupswrapper # Brother generic CUPS wrapper
      ];
    };

    # Enable gnome-keyring for 1Password secret storage
    gnome.gnome-keyring.enable = true;

    # Enable automatic trim
    fstrim.enable = true;

    # Bluetooth configuration
    blueman.enable = true;

    # Sound via Pipewire (modern replacement for PulseAudio)
    pulseaudio.enable = false; # Disable old audio system
    pipewire = {
      enable = true;
      alsa.enable = true; # ALSA compatibility
      alsa.support32Bit = true; # 32-bit app support
      pulse.enable = true; # PulseAudio compatibility
      jack.enable = true;
      wireplumber.extraConfig = {
        "10-default-volumes" = {
          "wireplumber.settings" = {
            # Lower default volume for newly connected audio hardware sinks
            "device.routes.default-sink-volume" = 0.7;
            # Lower baseline volume for completely new app streams
            "node.stream.default-playback-volume" = 0.7;
            # Ensure it saves individual app volume settings aggressively
            "node.stream.restore-props" = true;
          };
        };
      };
    };
    orca.enable = true;
  };

  security.rtkit.enable = true; # Real-s scheduling for audio

  # Enable PAM authentication for screen locking
  security.pam.services.hyprlock = { };

  # Timezone and Locale
  time.timeZone = "Africa/Nairobi";
  i18n.defaultLocale = "en_GB.UTF-8";

  # User account configuration
  users.users.dbuturu = {
    isNormalUser = true;
    description = "Daniel Kigen Buturu";
    extraGroups = [
      "networkmanager"
      "wheel"
    ]; # wheel = sudo access
  };

  # Home-Manager configuration - manages user environment
  home-manager = {
    useGlobalPkgs = true; # Use system nixpkgs
    useUserPackages = true; # Install to user profile
    backupFileExtension = "backup"; # Backup existing files instead of failing
    extraSpecialArgs = {
      inherit pkgs-unstable theme;
      nixvim = inputs.nixvim;
    }; # Pass variables to home config
    users.dbuturu =
      { ... }:
      {
        # User configuration defined in home.nix
      };
  };

  # Nix configuration
  nix = {
    settings = {
      trusted-users = [
        "root"
        "dbuturu"
      ]; # Users who can configure Nix
      experimental-features = [
        "nix-command"
        "flakes"
      ]; # Enable new Nix CLI
      download-buffer-size = 134217728; # 128MB download buffer (default: 64MB)

      # Development environment optimization
      keep-outputs = true; # Keep build outputs for development shells
      keep-derivations = true; # Keep derivations for development shells

      # Automatic store optimization to reduce disk usage
      auto-optimise-store = true;
    };

    # Automatic garbage collection - runs daily and keeps only last 3 days
    gc = {
      automatic = true;
      dates = "daily"; # Run every day at 03:15
      options = "--delete-older-than 3d"; # Keep only last 3 days (very aggressive)
    };
  };

  nixpkgs.config.allowUnfree = true; # Allow proprietary software

  # Run user garbage collection alongside system cleanup
  systemd.user.services.nix-gc-user = {
    description = "Nix Garbage Collector (User)";
    script = "${pkgs.nix}/bin/nix-collect-garbage --delete-older-than 3d";
    serviceConfig = {
      Type = "oneshot";
      User = "dbuturu";
    };
  };

  systemd.user.timers.nix-gc-user = {
    description = "Nix Garbage Collection Timer (User)";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      RandomizedDelaySec = "1800"; # 30min random delay
      Persistent = true;
    };
  };

  # Ensure NFS state directories exist
  systemd.tmpfiles.rules = [
    "d /var/lib/nfs 0755 root root"
    "d /var/lib/nfs/sm 0755 root root"
    "d /var/lib/nfs/sm.bak 0755 root root"
  ];

  hardware = {
    # NVIDIA driver configuration
    nvidia = {
      modesetting.enable = true; # Required for Wayland
      open = false; # Use proprietary driver (better gaming performance)
      nvidiaSettings = true; # Include nvidia-settings GUI
      package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
      # Stable driver version
      # package = config.boot.kernelPackages.nvidiaPackages.stable;

      # Enable power management and persistence for GPU control
      powerManagement.enable = true;
      powerManagement.finegrained = false;
    };
    # Bluetooth configuration
    bluetooth.enable = true;
    bluetooth.powerOnBoot = true;

    # Graphics configuration for gaming and GPU acceleration
    graphics = {
      enable = true;
      enable32Bit = true; # Required for Wine/Steam Proton games
    };
  };

  # Automatic system updates disabled - manual updates on Sundays
  system.autoUpgrade.enable = false;

  system.stateVersion = "25.11";
}
