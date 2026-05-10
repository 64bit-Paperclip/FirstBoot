#!/bin/bash
# =============================================================================
# lib/ui.sh — User Interface Functions
# Sourced by firstboot.sh after globals.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================


section() {
    local title="$1"
    local title_len=${#title}
    local total=80
    local prefix="═══[ "
    local suffix_len=$(( total - ${#prefix} - title_len - 3 ))
    local suffix=$(printf '%0.s-' $(seq 1 $suffix_len))
    echo ""
    echo -e "${CYAN}${prefix}${NC}${BOLD}${title}${CYAN} ]${suffix}${NC}"
    echo ""
}

draw_banner() {
	echo ""
	echo -e "${CYAN}${BOLD}"
	echo "╔══════════════════════════════════════════════════════════════════════════════╗"
	echo "║                                FIRSTBOOT v1.0                                ║"
	echo "╠══════════════════════════════════════════════════════════════════════════════╣"
	echo "║                             Server Setup Toolkit                             ║"
	echo "║                               Ubuntu 24.04 LTS                               ║"
	echo "╚══════════════════════════════════════════════════════════════════════════════╝"
	echo -e "${NC}"
}

draw_main_menu() {
    section "Main Menu"
    echo "    1)  System Status"
    echo "    2)  Setup a Group"
    echo "    3)  Manage a Service"
    echo "    4)  Run an Action"
    echo ""
    echo "    0)  Exit"
    echo ""
}

confirm_prompt() {
    local prompt="${1:-Are you sure?}"
    local answer
    while true; do
        read -rp "  $prompt (yes/no): " answer
        case "$answer" in
            yes|y) return 0 ;;
            no|n)  return 1 ;;
            *)     warn "Please enter yes/no or y/n." ;;
        esac
    done
}

required_prompt() {
    local prompt="$1"
    local varname="$2"
    local value
    while true; do
        read -rp "  $prompt: " value
        [ -n "$value" ] && break
        warn "This field cannot be empty."
    done
    printf -v "$varname" '%s' "$value"
}


export -f section

