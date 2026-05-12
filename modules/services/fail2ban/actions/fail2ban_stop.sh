#!/bin/bash
# =============================================================================
# modules/services/fail2ban/actions/fail2ban_stop.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Stop --------------------------------------------------------------------
action_fail2ban_stop() {
    if ! is_fail2ban_installed; then
        warn "Fail2ban is not installed."
        return 1
    fi
    if ! is_fail2ban_running; then
        warn "Fail2ban is not running."
        return 1
    fi
    systemctl stop fail2ban || { error "Failed to stop Fail2ban."; return 1; }
    info "Fail2ban stopped."
}
register_action "Stop Fail2ban|fail2ban_stop|action_fail2ban_stop"
