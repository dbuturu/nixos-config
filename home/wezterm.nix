{ pkgs, ... }:

{
  programs.wezterm = {
    enable = true;
    
    extraConfig = ''
      local wezterm = require 'wezterm'
      local act = wezterm.action
      local config = wezterm.config_builder()

      -------------------------------------------------------------------------
      -- Appearance & Theme
      -------------------------------------------------------------------------
      config.color_scheme = 'Catppuccin Mocha'
      
      -- Text & Typography
      config.font = wezterm.font_with_fallback({
        { family = 'JetBrains Mono', weight = 'Regular' },
        { family = 'Symbols Nerd Font Mono' },
      })
      config.font_size = 11.5
      config.line_height = 1.1

      -- Window Configuration (Suckless Style Alignment)
      config.window_padding = {
        left = 8,
        right = 8,
        top = 8,
        bottom = 8,
      }
      config.use_fancy_tab_bar = false
      config.hide_tab_bar_if_only_one_tab = true
      config.window_background_opacity = 0.95

      -------------------------------------------------------------------------
      -- Pure Keyboard Navigation (No Mouse Scrolling)
      -------------------------------------------------------------------------
      config.keys = {
        -- Tap Ctrl+Shift+Space to immediately enter Vim navigation mode
        {
          key = 'Space',
          mods = 'ALT',
          action = act.ActivateCopyMode,
        },
        -- Simple clip management integration
        {
          key = 'c',
          mods = 'ALT',
          action = act.CopyTo 'Clipboard',
        },
        {
          key = 'v',
          mods = 'ALT',
          action = act.PasteFrom 'Clipboard',
        },
      }

      -------------------------------------------------------------------------
      -- Visual Mode Status Indicator
      -------------------------------------------------------------------------
      -- Updates the bottom-right corner to scream "COPY MODE" when active,
      -- ensuring you never get lost inside a dead state buffer.
      wezterm.on('update-right-status', function(window, pane)
        local name = window:active_key_table()
        if name == 'copy_mode' then
          window:set_right_status(wezterm.format({
            { Background = { Color = '#b4befe' } }, -- Catppuccin Lavender
            { Foreground = { Color = '#11111b' } }, -- Catppuccin Crust
            { Text = '  COPY MODE  ' },
          }))
        else
          window:set_right_status('')
        end
      end)

      return config
    '';
  };
}
