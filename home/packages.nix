{
  pkgs,
  pkgs-unstable,
  nixvim,
  ...
}: {
  home.packages =
    # Core System Utilities (Stable)
    (with pkgs; [
      libnotify # Desktop notifications
      pulsemixer # PipeWire volume control
      wiremix # PipeWire mixer
      btop # System monitor
      lm_sensors # Hardware sensors
      nvtopPackages.nvidia # GPU monitoring for btop
      bluetui # Bluetooth control
    ])
    ++
    # File Manager (Stable)
    (with pkgs; [
      thunar # GUI file manager with drag-and-drop
      thunar-volman # Automatic device management
      thunar-archive-plugin # Archive file support
    ])
    ++
    # CLI Tools (Stable) - themed with Catppuccin
    (with pkgs; [
      eza # Modern 'ls' replacement
      bat # Modern 'cat' with syntax highlighting
      fzf # Fuzzy finder
      zoxide # Smart 'cd' command
      gh # GitHub CLI
      yazi # File Managers
      zip # Zip zips
      unzip # Unzip zips
    ])
    ++
    # Fonts and Themes (Stable)
    (with pkgs; [
      nerd-fonts.jetbrains-mono # Programming font with icons
      # papirus-icon-theme - provided by Catppuccin
      libsForQt5.qtstyleplugin-kvantum # Qt theme engine for Catppuccin
      qt6Packages.qtstyleplugin-kvantum # Qt6 theme engine
    ])
    ++
    # Essential Development Tools (Unstable - Latest Features)
    (with pkgs-unstable; [
      claude-code # AI coding assistant
      python3 # Python interpreter
      uv # Python tool runner (pipx alternative)
      nodejs # JavaScript runtime
      android-tools # android tools
    ])
    ++
    # Media and Screenshot Tools (Unstable)
    (with pkgs-unstable; [
      grim # Wayland screenshot tool
      slurp # Screen area selection
      wl-clipboard # Wayland clipboard
      cliphist # Clipboard history manager
      loupe # Image viewer
      mpd # Music player backend
      ncmpcpp # Music player frontend
      ani-cli # Anime player
    ])
    ++
    # Gaming (Unstable - Latest Compatibility)
    (with pkgs-unstable; [
      steam # Gaming platform
      protonup-qt # Proton version manager
      gamemode # Game performance optimization
      gamescope # Gaming compositor
      vulkan-tools # Graphics debugging tools
      prismlauncher # Minecraft launcher (maintained alternative)
      mindustry # Sandbox tower defence game
      luanti # An open-source voxel game creation platform
    ])
    ++
    # Productivity Applications (Unstable)
    (with pkgs-unstable; [
      obsidian # Note-taking and knowledge management
      notesnook # Note-taking
      newsboat # RSS feed reader
      mutt-wizard # Setup mutt
      libreoffice # Office suite
      zathura # PDF reader
      numbat # High precision scientific calculator with full support for physical units
      libqalculate # Qalculate! library and CLI
      mission-planner # ArduPilot ground station
      qgis # Free and Open Source Geographic Information System
    ])
    ++ [
      nixvim.packages.x86_64-linux.default
    ]
    ++
    # Communication (Unstable)
    (with pkgs-unstable; [
      discord # Voice and text chat
      neomutt # Email
      abook # Phonebook
    ])
    ++
    # Audio Production Tools (Mixed)
    (with pkgs; [
      audacity # Free audio editor
      sox # Sound processing library
      alsa-utils # ALSA utilities (PipeWire compatible)
    ])
    ++ (with pkgs-unstable; [
      ffmpeg-full # Comprehensive media conversion
      mpv # Media player with codec support
    ]);
}
