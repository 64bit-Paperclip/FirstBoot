
#!/bin/bash
# =============================================================================
# modules/services/fail2ban/actions/fail2ban_reload.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Reload ------------------------------------------------------------------
action_fail2ban_reload() {
    if ! is_fail2ban_installed; then
        warn "Fail2ban is not installed."
        return 1
    fi
    if ! is_fail2ban_running; then
        warn "Fail2ban is not running."
        return 1
    fi
    systemctl reload fail2ban || { error "Failed to reload Fail2ban."; return 1; }
    info "Fail2ban reloaded."
}
register_action "Reload Fail2ban|fail2ban_reload|action_fail2ban_reload"
