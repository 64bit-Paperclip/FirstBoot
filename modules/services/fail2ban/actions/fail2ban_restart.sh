
#!/bin/bash
# =============================================================================
# modules/services/fail2ban/actions/fail2ban_restart.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Restart -----------------------------------------------------------------
action_fail2ban_restart() {
    if ! is_fail2ban_installed; then
        warn "Fail2ban is not installed."
        return 1
    fi
    systemctl restart fail2ban || { error "Failed to restart Fail2ban."; return 1; }
    if ! is_fail2ban_running; then
        warn "Fail2ban may not have restarted correctly -- check: journalctl -u fail2ban"
        return 1
    fi
    info "Fail2ban restarted."
}
register_action "Restart Fail2ban|fail2ban_restart|action_fail2ban_restart"
