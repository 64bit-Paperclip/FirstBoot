#!/bin/bash
# =============================================================================
# modules/services/unattended/actions/unattended_uninstall.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Action ------------------------------------------------------------------
action_unattended_uninstall() {

    if ! is_unattended_installed; then
        warn "Unattended Upgrades is not installed."
        return 1
    fi

    section "Uninstalling Unattended Upgrades"

    confirm_prompt "This will remove Unattended Upgrades and its configuration. Are you sure?" || return 1

    info "Stopping Unattended Upgrades..."
    systemctl stop unattended-upgrades
    systemctl disable unattended-upgrades

    info "Removing package..."
    apt purge -y unattended-upgrades apt-listchanges || { error "Failed to remove Unattended Upgrades."; return 1; }
    apt autoremove -y

    info "Removing configuration..."
    rm -f /etc/apt/apt.conf.d/50unattended-upgrades
    rm -f /etc/apt/apt.conf.d/20auto-upgrades

    info "Unattended Upgrades uninstalled."
}

# --- Register ----------------------------------------------------------------
register_action "Uninstall Unattended Upgrades|unattended_uninstall|action_unattended_uninstall"