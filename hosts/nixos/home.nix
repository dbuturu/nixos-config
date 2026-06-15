# home.nix
{
  pkgs,
  pkgs-unstable,
  catppuccin,
  ...
}: {
  # Set the default shell for the user at the system level
  users.users.dbuturu.shell = pkgs.zsh;

  # Home Manager configuration for user environment
  home-manager.users.dbuturu = {
    imports = [
      # Core Global Plugins
      catppuccin.homeModules.catppuccin

      ../../home/default.nix
    ];
    # Global Catppuccin configuration
    catppuccin = {
      enable = true;
      autoEnable = true;
      flavor = "mocha"; # Dark theme - options: latte, frappe, macchiato, mocha
    };

    home.stateVersion = "26.05";
  };
}
