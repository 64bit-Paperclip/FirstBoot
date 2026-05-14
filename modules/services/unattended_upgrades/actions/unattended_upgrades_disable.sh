#!/bin/bash
# =============================================================================
# modules/services/unattended/actions/unattended_disable.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Action ------------------------------------------------------------------
action_unattended_disable() {
    section "Disable Unattended Upgrades"

    if ! is_unattended_upgrades_installed; then
        warn "Unattended Upgrades is not installed."
        return 1
    fi

    local _uau_di_active=false
    systemctl is-active --quiet apt-daily.timer 2>/dev/null         && _uau_di_active=true
    systemctl is-active --quiet apt-daily-upgrade.timer 2>/dev/null && _uau_di_active=true

    if [ "$_uau_di_active" = false ]; then
        warn "Unattended Upgrades timers are already inactive."
        return 1
    fi

    warn "Disabling will stop automatic security updates."
    confirm_prompt "Are you sure?" || return 1

    systemctl disable --now apt-daily.timer apt-daily-upgrade.timer 2>/dev/null \
        || { error "Failed to disable timers."; return 1; }

    info "Unattended Upgrades disabled."
}

# --- Register ----------------------------------------------------------------
register_action "Disable Unattended Upgrades|unattended_disable|action_unattended_disable"