# home/shell.nix
{ pkgs, ... }:

{
  # Zsh Configuration
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    
    # Completion settings
    completionInit = ''
      autoload -U compinit
      compinit
      
      # Case insensitive completion
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
      
      # Better completion behavior
      zstyle ':completion:*' menu select
      zstyle ':completion:*' use-cache on
      zstyle ':completion:*' cache-path ~/.zsh/cache
    '';

    # Add your aliases here
    shellAliases = {
      ls = "eza --icons=auto";
      l = "eza --icons=auto";
      ll = "eza -l --icons=auto --git";
      la = "eza -la --icons=auto --git";
      lt = "eza --tree --level=2 --icons";
      cat = "bat";

      # Verbosity and settings
      cp = "cp -iv";
      mv = "mv -iv";
      rm = "rm -vI";
      bc = "bc -ql";
      rsync = "rsync -vrPlu";
      mkd = "mkdir -pv";
      yt = "yt-dlp --embed-metadata -i";
      yta = "yt -x -f bestaudio/best";
      ytt = "yt --skip-download --write-thumbnail";
      ffmpeg = "ffmpeg -hide_banner";

      # Colorize commands when possible
      grep = "grep --color=auto";
      diff = "diff --color=auto";
      ccat = "bat --style=plain";
      ip = "ip -color=auto";

      # Abbreviations
      ka = "killall";
      g = "git";
      trem = "transmission-remote";
      YT = "youtube-viewer";
      sdn = "shutdown -h now";
      e = "$EDITOR";
      v = "$EDITOR";
      xq = "xbps-query";
      z = "zathura";

      # Directory aliases
      cac = "cd \${XDG_CACHE_HOME:-$HOME/.cache}";
      cf = "cd \${XDG_CONFIG_HOME:-$HOME/.config}";
      D = "cd \${XDG_DOWNLOAD_DIR:-$HOME/Downloads}";
      d = "cd \${XDG_DOCUMENTS_DIR:-$HOME/Documents}";
      dt = "cd \${XDG_DATA_HOME:-$HOME/.local/share}";
      rr = "cd $HOME/.local/src";
      h = "cd $HOME";
      m = "cd \${XDG_MUSIC_DIR:-$HOME/Music}";
      mn = "cd /mnt";
      pp = "cd \${XDG_PICTURES_DIR:-$HOME/Pictures}";
      sc = "cd $HOME/.local/bin";
      src = "cd $HOME/.local/src";
      vv = "cd \${XDG_VIDEOS_DIR:-$HOME/Videos}";
    };

    # Oh My Zsh provides themes and plugins for zsh
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" ]; # Plugin names from oh-my-zsh repository
    };

    # initContent runs after zsh starts - for shell integrations and environment
    initContent = ''
      # Source user environment variables if the file exists
      [ -f ~/.env ] && source ~/.env
      
      # Initialize tools
      eval "$(zoxide init zsh --cmd cd)"
      
      # --- VI Mode Setup ---
      # Enable vi-mode keybindings, equivalent to 'set editing-mode vi'
      bindkey -v

      # Function to change cursor shape for different vi modes.
      # This replicates the 'vi-ins-mode-string' and 'vi-cmd-mode-string' behavior.
      function zle-keymap-select () {
        case $KEYMAP in
          vicmd) echo -ne '\e[2 q';;      # block cursor for command mode
          viins|main) echo -ne '\e[6 q';; # bar cursor for insert mode
        esac
      }
      zle -N zle-keymap-select
      # Set initial cursor to bar for insert mode
      echo -ne '\e[6 q'

      bindkey '^l' clear-screen
      bindkey '^a' beginning-of-line

      # Autosuggestion settings for better visibility and behavior
      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#666680,bold"
      ZSH_AUTOSUGGEST_STRATEGY=(history completion)
      
      # Keybindings for autocompletion
      bindkey '^I' complete-word              # Tab for completion
      bindkey '^[[Z' reverse-menu-complete    # Shift+Tab for reverse completion
      bindkey '^ ' autosuggest-accept         # Ctrl+Space to accept suggestion
      bindkey '^f' autosuggest-accept         # Ctrl+f to accept suggestion (alternative)
    '';
  };

  # Starship Prompt Configuration
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  # Atuin Shell History
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
  };

  # Zellij Terminal Multiplexer
  programs.zellij = {
    enable = true;
  };
}
