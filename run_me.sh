#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

# =============================================================================
# Definitions
# =============================================================================

SECTIONS=("core" "hyprland" "dev" "gpu" "gaming" "comms")

# =============================================================================
# Prerequisites
# =============================================================================

# Install paru to access AUR (Arch User Repository)
# Install dialog to display dialog windows with choices in text interface
pacman_install paru dialog

# =============================================================================
# CORE: base + git + shell
# =============================================================================

function install_section_core {
    show_dialog_section_begin "Core" "Fonts, pretty terminal"

    # Base packages
    pacman_update
    pacman_upgrade

    # Google Chrome
    aur_install google-chrome

    # Nerd fonts
    aur_install extra/ttf-firacode-nerd

    # Starship
    curl -sS https://starship.rs/install.sh | sh -s -- -y

    # FZF - gigachad CTR-R search
    pacman_install fzf

    # Copy config files
    mkdir -p ~./config && cp "$(pwd)/.config/starship.toml" ~/.config/starship.toml
    cp -r "$(pwd)/.config/fish" ~/.config
    cp -r "$(pwd)/.config/kitty" ~/.config

    show_dialog_section_finished "Core"
}

# =============================================================================
# DESKTOP ENVIRONMENT: Bringing Hyprland to state useful for a human being
# =============================================================================

function install_section_hyprland {
    show_dialog_section_begin "Desktop Environment" "Hyprland related modifications"

    # Fix file selector opened by VS Code
    pacman_install xdg-desktop-portal xdg-desktop-portal-hyprland

    # Hyprpolkitagent - required for GUI to request elevated privileges
    # https://wiki.hypr.land/Hypr-Ecosystem/hyprpolkitagent/
    pacman_install hyprpolkitagent

    # Brightnessctl - control screen brightness
    # Gammastep - night light
    pacman_install brightnessctl gammastep

    # Install Rofi - launcher 
    # Customized via .config/rofi 
    pacman_install rofi-wayland
    cp -r "$(pwd)/.config/rofi" ~/.config

    # Install hyprpicker - color picker
    pacman_install hyprpicker

    # Install Waybar - customizable info bar
    sudo usermod -aG input $USER
    pacman_install waybar
    cp -r "$(pwd)/.config/waybar" ~/.config



    show_dialog_section_finished "Desktop Environment"
}

# =============================================================================
# DEVELOPMENT: base + git + shell
# =============================================================================

function install_section_dev {
    show_dialog_section_begin "Development" "Python, Terraform, Docker, Github CLI, AWS CLI"

    pacman_install base-devel github-cli direnv

    # Python related
    pacman_install tk python python-pip pyenv 

    # tldr command
    pacman_install tealdeer
    tldr --update

    # Visual Studio Code
    pacman_install code

    # Docker
    pacman_install docker docker-compose
    sudo systemctl enable docker
    sudo usermod -aG docker $USER

    # Terraform 
    pacman_install terraform

    # AWS CLI
    pacman_install aws-cli

    # Git identity
    local current_email=$(git config --global user.email 2>/dev/null)
    local current_name=$(git config --global user.name 2>/dev/null)
    local git_email=$(dialog --stdout --inputbox "Git email:" 8 50 "$current_email")
    local git_name=$(dialog --stdout --inputbox "Git name:" 8 50 "$current_name")
    [ -n "$git_email" ] && git config --global user.email "$git_email"
    [ -n "$git_name" ] && git config --global user.name "$git_name"

    show_dialog_section_finished "Development"
}
# =============================================================================
# GPU: auto-detect and install drivers
# =============================================================================

function install_section_gpu {
    local gpu_type=$(detect_gpu)
    show_dialog_section_begin "GPU" "$gpu_type drivers"

    case "$gpu_type" in
        nvidia)
            pacman_install nvidia nvidia-utils lib32-nvidia-utils nvidia-settings
            show_dialog_section_finished "$gpu_type drivers installed"
            ;;
        amd)
            pacman_install mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon
            show_dialog_section_finished "$gpu_type drivers installed"
            ;;
        intel)
            pacman_install mesa lib32-mesa vulkan-intel lib32-vulkan-intel
            show_dialog_section_finished "$gpu_type drivers installed"
            ;;
        *)
            show_dialog_section_finished "$GPU NOT DETECTED - INSTALL DRIVERS MANUALLY"
            return 1
            ;;
    esac

    
}

# =============================================================================
# GAMING - CachyOS meta-packages
# =============================================================================

function install_section_gaming {
    show_dialog_section_begin "Gaming" "CachyOS gaming packages"

    # CachyOS gaming meta-packages
    # - cachyos-gaming-meta: Proton, Wine, 32-bit libs, Vulkan tools, audio plugins
    # - cachyos-gaming-applications: Steam, gamescope, mangohud, gamemode, launchers
    pacman_install cachyos-gaming-meta cachyos-gaming-applications

    show_dialog_section_finished "Gaming"
}

# =============================================================================
# COMMUNICATORS - Slack, Vesktop (Discord)
# =============================================================================

function install_section_comms {
    show_dialog_section_begin "Communicators" "Slack, Vencord"

    aur_install vesktop-bin slack-desktop-wayland

    show_dialog_section_finished "Communicators"
}

# =============================================================================
# RUNNER
# =============================================================================

show_dialog_menu() {
    local args=()
    args+=("ALL" ">>> Install everything <<<" "OFF")
    for i in "${!SECTIONS[@]}"; do
        args+=("$((i+1))" "${SECTIONS[i]} - ${DESCRIPTIONS[i]}" "OFF")
    done

    local choices
    choices=$(dialog --stdout --title "CachyOS Fresh Setup" \
        --checklist "SPACE=toggle, ENTER=confirm" \
        20 90 15 \
        "${args[@]}")

    echo "$choices"
}

function show_dialog_done() {
    dialog --title " Complete " --msgbox "\nAll done! Press Enter to exit.\n" 7 45
}

install_sections() {
    local indices="$1"

    if [[ "$indices" == *"ALL"* ]]; then
        for section in "${SECTIONS[@]}"; do
            "install_section_${section}"
        done
        return
    fi

    for index in $indices; do
        index="${index//\"/}"
        local section="${SECTIONS[index-1]}"
        "install_section_${section}"
    done
}

main() {
    local input=""

    if [[ "$1" == "--all" ]]; then
        input="ALL"

    elif [[ "$#" -eq 0 ]]; then
        input=$(show_dialog_menu)
        if [[ -z "$input" ]]; then
            echo "No sections selected. Exiting."
            exit 0
        fi

    else
        input="$*"
    fi

    install_sections "$input"
}

main "$@"
