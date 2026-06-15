# home/scripts.nix
{pkgs, ...}: let
  # writeShellScriptBin creates a derivation with an executable in bin/
  screenshotScript = pkgs.writeShellScriptBin "screenshot" ''
    #!/usr/bin/env bash
    set -euo pipefail

    # Directory where screenshots will be saved
    SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
    mkdir -p "$SCREENSHOT_DIR"

    # Filename with timestamp
    FILENAME="$SCREENSHOT_DIR/$(date +'%Y-%m-%d_%H-%M-%S').png"

    case "$1" in
      select)
        # slurp lets user select area, grim captures it
        # tee saves to file AND pipes to clipboard simultaneously
        grim -g "$(slurp)" -t png - | tee "$FILENAME" | wl-copy
        ;;
      full)
        # grim without -g captures entire screen
        grim -t png - | tee "$FILENAME" | wl-copy
        ;;
      *)
        echo "Usage: $0 {select|full}"
        exit 1
        ;;
    esac

    # Send a notification with the screenshot as the icon.
    # mako is already installed from your packages.nix
    notify-send "Screenshot Taken" "Saved as <i>$(basename "$FILENAME")</i> and copied to clipboard." -i "$FILENAME"
  '';

  # Combined temperature display for Waybar
  waybarTempsScript = pkgs.writeShellScriptBin "waybar-temps" ''
    #!/usr/bin/env bash

    # Find CPU temperature from coretemp sensor
    CPU_TEMP="N/A"
    for sensor in /sys/class/hwmon/hwmon*/temp*_input; do
      if [ -f "$sensor" ]; then
        name_file="$(dirname "$sensor")/name"
        if [ -f "$name_file" ]; then
          name=$(cat "$name_file" 2>/dev/null)
          if [ "$name" = "coretemp" ]; then
            temp=$(cat "$sensor" 2>/dev/null)
            if [ -n "$temp" ]; then
              CPU_TEMP=$((temp / 1000))
              break
            fi
          fi
        fi
      fi
    done

    # Get GPU temperature
    GPU_TEMP=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null)
    if [ -z "$GPU_TEMP" ]; then
      GPU_TEMP="N/A"
    fi

    # Format output
    echo "🌡️ $CPU_TEMP°C | $GPU_TEMP°C"
  '';

  # Find temperature sensors script
  findTempSensors = pkgs.writeShellScriptBin "find-temp-sensors" ''
    #!/usr/bin/env bash
    echo "=== Finding all temperature sensors ==="
    echo

    echo "--- Hardware Monitor Sensors ---"
    for sensor in /sys/class/hwmon/hwmon*/temp*_input; do
      if [ -f "$sensor" ]; then
        name_file="$(dirname "$sensor")/name"
        if [ -f "$name_file" ]; then
          name=$(cat "$name_file" 2>/dev/null)
        else
          name="unknown"
        fi
        temp=$(cat "$sensor" 2>/dev/null)
        temp_c=$((temp / 1000))
        echo "$sensor -> $name: $temp_c°C"
      fi
    done

    echo
    echo "--- DRM Card Sensors ---"
    for sensor in /sys/class/drm/card*/device/hwmon/hwmon*/temp*_input; do
      if [ -f "$sensor" ]; then
        temp=$(cat "$sensor" 2>/dev/null)
        temp_c=$((temp / 1000))
        echo "$sensor -> GPU: $temp_c°C"
      fi
    done

    echo
    echo "--- NVIDIA GPU via nvidia-smi ---"
    if command -v nvidia-smi >/dev/null 2>&1; then
      nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null | while read temp; do
        echo "nvidia-smi -> GPU: $temp°C"
      done
    else
      echo "nvidia-smi not available"
    fi

    echo
    echo "--- NVIDIA GPU via nvidia-settings ---"
    if command -v nvidia-settings >/dev/null 2>&1; then
      temp=$(nvidia-settings -q [gpu:0]/GPUCoreTemp -t 2>/dev/null)
      if [ -n "$temp" ]; then
        echo "nvidia-settings -> GPU: $temp°C"
      else
        echo "nvidia-settings query failed"
      fi
    else
      echo "nvidia-settings not available"
    fi

    echo
    echo "--- Check if NVIDIA modules are loaded ---"
    lsmod | grep nvidia || echo "No nvidia modules loaded"
  '';

  # Script to create ~/.env file with user prompts
  createEnvScript = pkgs.writeShellScriptBin "create-env" ''
        #!/usr/bin/env bash

        ENV_FILE="$HOME/.env"

        echo "Creating environment variables file at $ENV_FILE"
        echo "Press Enter to skip any variable you don't want to set."
        echo

        # Create or backup existing file
        if [ -f "$ENV_FILE" ]; then
          echo "Backing up existing $ENV_FILE to $ENV_FILE.backup"
          cp "$ENV_FILE" "$ENV_FILE.backup"
        fi

        # Start with header
        cat > "$ENV_FILE" << 'EOF'
    # User environment variables
    # This file is sourced by bash and zsh on shell initialization
    # Edit this file to add or modify environment variables

    EOF

        # Prompt for each variable
        declare -A variables=(
          ["ANTHROPIC_API_KEY"]="Anthropic API key for Claude"
          ["WEATHER_LOCATION"]="Weather location (e.g., London,UK or New York,NY)"
        )

        for var in "''${!variables[@]}"; do
          echo -n "Enter $var (''${variables[$var]}): "
          read -r value

          if [ -n "$value" ]; then
            echo "export $var=\"$value\"" >> "$ENV_FILE"
            echo "✓ Set $var"
          else
            echo "⏭ Skipped $var"
          fi
        done

        echo
        echo "Environment file created at $ENV_FILE"
        echo "Variables will be available in new shell sessions."
        echo "Run 'source ~/.env' to load them in the current session."
  '';

  # Service status indicator script
  serviceStatusScript = pkgs.writeShellScriptBin "waybar-services" ''
    #!/usr/bin/env bash

    # Services to monitor
    declare -A services=(
      # ["ollama"]="🤖"
    )

    active_services=""
    inactive_count=0

    for service in "''${!services[@]}"; do
      if systemctl is-active --quiet "$service" 2>/dev/null; then
        active_services+="''${services[$service]}"
      else
        ((inactive_count++))
      fi
    done

    # Show active services and count of inactive ones
    if [ $inactive_count -gt 0 ]; then
      echo "$active_services ⚠️$inactive_count"
    else
      echo "$active_services"
    fi
  '';

  # Music visualizer script
  musicVisualizerScript = pkgs.writeShellScriptBin "waybar-music-viz" ''
    #!/usr/bin/env bash

    # Check if music is playing
    if ! playerctl status 2>/dev/null | grep -q "Playing"; then
      echo ""
      exit 0
    fi

    # Simple ASCII visualizer bars
    bars=("▁" "▂" "▃" "▄" "▅" "▆" "▇" "█")
    viz=""

    # Generate random visualization (in real setup, you'd use audio data)
    for i in {1..8}; do
      random_height=$((RANDOM % 8))
      viz+="''${bars[$random_height]}"
    done

    # Get current song info
    artist=$(playerctl metadata artist 2>/dev/null || echo "Unknown")
    title=$(playerctl metadata title 2>/dev/null || echo "Unknown")

    # Format: visualizer + song info
    echo "♪ $viz $title"
  '';

  # Weather widget script
  weatherScript = pkgs.writeShellScriptBin "waybar-weather" ''
    #!/usr/bin/env bash
    set -euo pipefail

    # Source environment variables
    if [ -f "$HOME/.env" ]; then
      source "$HOME/.env"
    fi

    # Default location (can be overridden in ~/.env)
    LOCATION="''${WEATHER_LOCATION:-London,UK}"

    # Weather API endpoint (using wttr.in - no API key needed)
    WEATHER_URL="https://wttr.in/$LOCATION?format=%c+%t"

    # Fetch weather data with timeout
    if ! weather_data=$(curl -s --connect-timeout 5 --max-time 10 "$WEATHER_URL" 2>/dev/null); then
      echo "🌡️ N/A"
      exit 0
    else
      echo $weather_data
    fi
  '';

  # VPN quick connect/disconnect script
  vpnScript = pkgs.writeShellScriptBin "vpn" ''
    #!/usr/bin/env bash

    case "$1" in
      connect)
        echo "Connecting to Belgium VPN..."
        nmcli --ask connection up "be-bru.prod.surfshark.comsurfshark_openvpn_udp"
        ;;
      disconnect)
        echo "Disconnecting from VPN..."
        nmcli connection down "be-bru.prod.surfshark.comsurfshark_openvpn_udp"
        echo "✓ Disconnected from VPN"
        ;;
      status)
        active_vpn=$(nmcli connection show --active | grep "be-bru.prod.surfshark.comsurfshark_openvpn_udp" | awk '{print $1}' | head -1)
        if [ -n "$active_vpn" ]; then
          echo "✓ Connected"
        else
          echo "✗ Disconnected"
        fi
        ;;
      *)
        echo "Usage: vpn {connect|disconnect|status}"
        echo "Examples:"
        echo "  vpn connect     # Connect to Belgium server"
        echo "  vpn disconnect  # Disconnect from VPN"
        echo "  vpn status      # Show connection status"
        ;;
    esac
  '';

  # Waybar VPN status widget script
  waybarVpnScript = pkgs.writeShellScriptBin "waybar-vpn" ''
    #!/usr/bin/env bash

    # Check if VPN is connected
    if nmcli connection show --active | grep -q "be-bru.prod.surfshark.comsurfshark_openvpn_udp"; then
      echo "🛡️"
    else
      echo "🔓"
    fi
  '';

  # Development environment initialization script
  devInitScript = pkgs.writeShellScriptBin "dev-init" ''
    #!/usr/bin/env bash
    set -euo pipefail

    TEMPLATE_DIR="/home/dbuturu/nixos-config/dev-templates"

    # Show usage if no arguments
    if [ $# -eq 0 ]; then
      echo "🚀 Development Environment Initializer"
      echo
      echo "Usage: dev-init <template>"
      echo
      echo "Available templates:"
      if [ -d "$TEMPLATE_DIR" ]; then
        for template in "$TEMPLATE_DIR"/*; do
          if [ -d "$template" ]; then
            template_name=$(basename "$template")
            echo "  📦 $template_name"
          fi
        done
      else
        echo "  ❌ Template directory not found: $TEMPLATE_DIR"
      fi
      echo
      echo "Examples:"
      echo "  dev-init python-ml    # Initialize Python ML environment"
      echo "  dev-init python-web   # Initialize Python web environment"
      echo "  dev-init nodejs       # Initialize Node.js environment"
      exit 0
    fi

    TEMPLATE="$1"
    TEMPLATE_PATH="$TEMPLATE_DIR/$TEMPLATE"

    # Check if template exists
    if [ ! -d "$TEMPLATE_PATH" ]; then
      echo "❌ Template '$TEMPLATE' not found"
      echo "Available templates:"
      for template in "$TEMPLATE_DIR"/*; do
        if [ -d "$template" ]; then
          template_name=$(basename "$template")
          echo "  📦 $template_name"
        fi
      done
      exit 1
    fi

    # Check if flake.nix already exists
    if [ -f "flake.nix" ]; then
      echo "⚠️  flake.nix already exists in current directory"
      echo -n "Overwrite? (y/N): "
      read -r response
      if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Cancelled"
        exit 0
      fi
    fi

    # Copy template files
    echo "📋 Copying template '$TEMPLATE'..."
    cp "$TEMPLATE_PATH/flake.nix" .

    # Create .envrc for direnv
    echo "📝 Creating .envrc..."
    echo "use flake" > .envrc

    # Allow direnv to load the environment
    echo "🔄 Allowing direnv..."
    direnv allow

    echo "✅ Development environment initialized!"
    echo "💡 Run 'nix develop' or just 'cd .' to enter the environment"

    # Show what was created
    echo
    echo "Created files:"
    echo "  📄 flake.nix (development environment)"
    echo "  📄 .envrc (direnv configuration)"
    echo
    echo "The environment will automatically load when you enter this directory."
  '';

  # Resolves relative to where scripts.nix is saved
  wallpaperSource = "$HOME/Pictures/Wallpapers";

  # Build a self-contained runtime binary wrapper package
  blend-wallpaper = pkgs.writeShellApplication {
    name = "blend-wallpaper";

    # Declare runtime dependencies explicitly so Nix patches their absolute paths
    runtimeInputs = [
      pkgs.imagemagick
      pkgs.awww
      pkgs.coreutils
      pkgs.gnugrep
    ];

    text = ''
      WALL_DIR="${wallpaperSource}"
      SUNRISE="$WALL_DIR/sunrise-001.jpg"
      MIDDAY="$WALL_DIR/midday-001.jpg"
      SUNSET="$WALL_DIR/sunset-001.jpg"
      NIGHT="$WALL_DIR/night-001.jpg"
      OUTPUT_WALL="/tmp/current_blended_wallpaper.jpg"

      HOUR=$(date +"%-H")
      MINUTE=$(date +"%-M")
      CURRENT_MINS=$(( HOUR * 60 + MINUTE ))

      MIN_07AM=$(( 7 * 60 ))
      MIN_11AM=$(( 11 * 60 ))
      MIN_04PM=$(( 16 * 60 ))
      MIN_06PM=$(( 18 * 60 ))

      if [ "$CURRENT_MINS" -ge "$MIN_07AM" ] && [ "$CURRENT_MINS" -lt "$MIN_11AM" ]; then
          TOTAL_WINDOW=$(( MIN_11AM - MIN_07AM ))
          ELAPSED=$(( CURRENT_MINS - MIN_07AM ))
          PERCENT=$(( ELAPSED * 100 / TOTAL_WINDOW ))
          INVERSE=$(( 100 - PERCENT ))
          magick "$SUNRISE" "$MIDDAY" -blend "''${INVERSE}x''${PERCENT}" "$OUTPUT_WALL"
      elif [ "$CURRENT_MINS" -ge "$MIN_11AM" ] && [ "$CURRENT_MINS" -lt "$MIN_04PM" ]; then
          cp "$MIDDAY" "$OUTPUT_WALL"
      elif [ "$CURRENT_MINS" -ge "$MIN_04PM" ] && [ "$CURRENT_MINS" -lt "$MIN_06PM" ]; then
          TOTAL_WINDOW=$(( MIN_06PM - MIN_04PM ))
          ELAPSED=$(( CURRENT_MINS - MIN_04PM ))
          PERCENT=$(( ELAPSED * 100 / TOTAL_WINDOW ))
          INVERSE=$(( 100 - PERCENT ))
          magick "$MIDDAY" "$SUNSET" -blend "''${INVERSE}x''${PERCENT}" "$OUTPUT_WALL"
      else
          cp "$NIGHT" "$OUTPUT_WALL"
      fi

      awww img "$OUTPUT_WALL" --transition-type fade --transition-step 10 --transition-fps 30
    '';
  };
in {
  # Add the script package to your user's profile
  home.packages = [
    screenshotScript
    findTempSensors
    waybarTempsScript
    createEnvScript
    serviceStatusScript
    musicVisualizerScript
    weatherScript
    waybarVpnScript
    vpnScript
    devInitScript
    blend-wallpaper
  ];
}
