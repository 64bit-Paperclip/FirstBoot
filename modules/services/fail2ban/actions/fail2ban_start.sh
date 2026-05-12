#!/bin/bash
# =============================================================================
# modules/services/fail2ban/actions/fail2ban_service_controls.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Start -------------------------------------------------------------------
action_fail2ban_start() {
    if ! is_fail2ban_installed; then
        warn "Fail2ban is not installed."
        return 1
    fi
    if is_fail2ban_running; then
        warn "Fail2ban is already running."
        return 1
    fi
    systemctl start fail2ban || { error "Failed to start Fail2ban."; return 1; }
    info "Fail2ban started."
}
register_action "Start Fail2ban|fail2ban_start|action_fail2ban_start"
