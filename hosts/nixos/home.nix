# home.nix
{ pkgs, pkgs-unstable, catppuccin, ... }:

{
  # Set the default shell for the user at the system level
  users.users.lrabbets.shell = pkgs.zsh;

  # Home Manager configuration for user environment
  home-manager.users.dbuturu = {
    import ../../home/default.nix
    # Global Catppuccin configuration
    catppuccin = {
      enable = true;
      flavor = "mocha"; # Dark theme - options: latte, frappe, macchiato, mocha
    };

    home.stateVersion = "25.05";
  };
}
