{
  description = "Dbuturu's NixOS Configuration";
  
  # Binary cache configuration for CUDA packages
  nixConfig = {
    extra-substituters = [
      "https://cuda-maintainers.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
    ];
  };

  inputs = {
    # Stable release branch for reliable system packages
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11"; 
    # Unstable branch for latest packages (Firefox, development tools, etc.)
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs"; # Use same nixpkgs version for consistency
    };

    # Catppuccin theming for comprehensive application support
    catppuccin.url = "github:catppuccin/nix/d75e3fe67f49728cb5035bc791f4b9065ff3a2c9";

    hyprland.url = "github:hyprwm/Hyprland";

    hy3 = {
      url = "github:outfoxxed/hy3";
      inputs.hyprland.follows = "hyprland"; # Prevents crashing from version mismatch
    };
  };
 
  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, catppuccin, hyprland, hy3, ... }@inputs: 
    let
      theme = import ./hosts/nixos/theme/theme.nix;
      system = "x86_64-linux";
      
      # Import unstable packages with unfree software enabled
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true; # Allow proprietary software like Steam, Discord, etc.
      };
    in
  {
    nixosConfigurations = {
      "nixos" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs pkgs-unstable theme catppuccin hyprland hy3; }; # Pass variables to all modules
        modules = [
          ./hosts/nixos/configuration.nix # System-level configuration
          home-manager.nixosModules.home-manager # User environment management
          catppuccin.nixosModules.catppuccin # Catppuccin theming support
        ];
      };
    };
  };
}
