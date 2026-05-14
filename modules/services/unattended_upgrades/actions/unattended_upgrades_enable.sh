#!/bin/bash
# =============================================================================
# modules/services/unattended/actions/unattended_enable.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Action ------------------------------------------------------------------
action_unattended_enable() {
    section "Enable Unattended Upgrades"

    if ! is_unattended_installed; then
        warn "Unattended Upgrades is not installed."
        return 1
    fi

    local _uau_en_already=true
    systemctl is-active --quiet apt-daily.timer 2>/dev/null         || _uau_en_already=false
    systemctl is-active --quiet apt-daily-upgrade.timer 2>/dev/null || _uau_en_already=false

    if [ "$_uau_en_already" = true ]; then
        warn "Unattended Upgrades timers are already active."
        return 1
    fi

    systemctl enable --now apt-daily.timer apt-daily-upgrade.timer 2>/dev/null \
        || { error "Failed to enable timers."; return 1; }

    info "Unattended Upgrades enabled."
}

# --- Register ----------------------------------------------------------------
register_action "Enable Unattended Upgrades|unattended_enable|action_unattended_enable"