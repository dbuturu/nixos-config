# ./nixos/portal.nix  — import this in your configuration.nix
#
# Fixes:
#   - File picker timing out (missing backend for FileChooser interface)
#   - org.freedesktop.portal.Desktop StartServiceByName timeout
#
# How xdg-desktop-portal selects a backend:
#   The [river] section below is matched when XDG_CURRENT_DESKTOP=river.
#   Each interface can route to a different backend:
#     wlr  → xdg-desktop-portal-wlr  (screenshot, screencast)
#     gtk  → xdg-desktop-portal-gtk  (file picker, colour picker, printing)

{ pkgs, ... }:

{
  xdg.portal = {
    enable = true;

    # wlr backend: screencast / screenshot on wlroots compositors (River, Sway)
    wlr.enable = true;

    # gtk backend: the only one that implements FileChooser
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

    # Per-interface routing for River
    config = {
      # Fallback for any desktop not explicitly listed
      common.default = [ "gtk" ];

      # River-specific routing
      river = {
        default                                      = [ "wlr" "gtk" ];
        "org.freedesktop.impl.portal.FileChooser"   = [ "gtk" ];
        "org.freedesktop.impl.portal.Screenshot"    = [ "wlr" ];
        "org.freedesktop.impl.portal.ScreenCast"    = [ "wlr" ];
        "org.freedesktop.impl.portal.Inhibit"       = [ "wlr" ];
      };
    };
  };
}
