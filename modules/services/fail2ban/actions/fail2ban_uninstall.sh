#!/bin/bash
# =============================================================================
# modules/services/fail2ban/actions/fail2ban_uninstall.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Action ------------------------------------------------------------------
action_fail2ban_uninstall() {

    if ! is_fail2ban_installed; then
        warn "Fail2ban is not installed."
        return 1
    fi

    section "Uninstalling Fail2ban"

    confirm "This will remove Fail2ban and all its configuration. Are you sure?" || return 1

    info "Stopping Fail2ban..."
    systemctl stop fail2ban
    systemctl disable fail2ban

    info "Removing Fail2ban..."
    apt purge -y fail2ban || { error "Failed to remove Fail2ban."; return 1; }
    apt autoremove -y

    info "Removing configuration..."
    rm -rf /etc/fail2ban

    info "Fail2ban uninstalled."
}

# --- Register ----------------------------------------------------------------
register_action "Uninstall Fail2ban|fail2ban_uninstall|action_fail2ban_uninstall"