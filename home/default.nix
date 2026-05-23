{
    imports = [
      # Catppuccin theming system
      catppuccin.homeModules.catppuccin
      
      # Window manager and desktop environment
      ./hyprland.nix      # Hyprland WM configuration
      ./waybar.nix        # Status bar
      ./wofi.nix          # Application launcher
      ./wlogout.nix       # Logout menu
      ./swww/swww.nix          # Animated wallpaper manager
      ./hyprlock/hyprlock.nix   # Screen locker
      
      # Applications and tools
      ./packages.nix      # System packages
      # ./python.nix      # Python development environment - moved to project flakes
      ./cli-tools.nix     # CLI tools with Catppuccin theming
      ./browsers.nix      # Web browsers (Firefox & Brave)
      ./vscode.nix        # Code editor
      ./neovim.nix        # Terminal editor
      ./wezterm.nix         # Terminal emulator
      ./1password.nix     # Password manager
      
      # Shell and development environment
      ./shell.nix         # Zsh configuration
      ./git.nix           # Git settings
      ./scripts.nix       # Custom scripts
      ./direnv.nix        # Development environment management
      
      # System integration
      ./environment.nix   # Environment variables and secrets
      ./default-apps.nix  # Default applications
      ./service.nix       # User services
      ./gtk.nix           # GTK theming
    ];
}
