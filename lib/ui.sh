#!/bin/bash
# =============================================================================
# lib/ui.sh — User Interface Functions
# Sourced by firstboot.sh after globals.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

draw_banner() {
	echo ""
	echo -e "${CYAN}${BOLD}"
	echo "  ╔════════════════════════════════════════════════════════════════════════════╗"
	echo "  ║                               FIRSTBOOT v1.0                               ║"
	echo "  ╠════════════════════════════════════════════════════════════════════════════╣"
	echo "  ║                            Server Setup Toolkit                            ║"
	echo "  ║                              Ubuntu 24.04 LTS                              ║"
	echo "  ╚════════════════════════════════════════════════════════════════════════════╝"
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
    echo "  ────────────────────────────────────────────────────"
}

draw_groups_menu() {
    echo ""
    echo "  ── Setup a Group ────────────────────────────────────"
    echo ""
    local i=1
    for entry in "${SERVICE_GROUPS[@]}"; do
        IFS='|' read -r label name entry_fn <<< "$entry"
        printf "    %d)  %s\n" "$i" "$label"
        (( i++ ))
    done
    echo ""
    echo "    0)  Back"
    echo ""
    echo "  ────────────────────────────────────────────────────"
}

draw_services_menu() {
    echo ""
    echo "  ── Manage a Service ─────────────────────────────────"
    echo ""
    local i=1
    for entry in "${SERVICES[@]}"; do
        IFS='|' read -r label svc pkg svcvar groups entry_fn <<< "$entry"
        printf "    %d)  %-20s %s\n" "$i" "$label" "$(colorize_status "${!svcvar:-not installed}")"
        (( i++ ))
    done
    echo ""
    echo "    0)  Back"
    echo ""
    echo "  ────────────────────────────────────────────────────"
}

draw_actions_menu() {
    echo ""
    echo "  ── Run an Action ────────────────────────────────────"
    echo ""
    local i=1
    for entry in "${ACTIONS[@]}"; do
        IFS='|' read -r label name entry_fn <<< "$entry"
        printf "    %d)  %s\n" "$i" "$label"
        (( i++ ))
    done
    echo ""
    echo "    0)  Back"
    echo ""
    echo "  ────────────────────────────────────────────────────"
}