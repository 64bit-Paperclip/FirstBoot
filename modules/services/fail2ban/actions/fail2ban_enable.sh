
#!/bin/bash
# =============================================================================
# modules/services/fail2ban/actions/fail2ban_enable.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Enable on boot ----------------------------------------------------------
action_fail2ban_enable() {
    if ! is_fail2ban_installed; then
        warn "Fail2ban is not installed."
        return 1
    fi
    if systemctl is-enabled --quiet fail2ban; then
        warn "Fail2ban is already enabled."
        return 1
    fi
    systemctl enable fail2ban || { error "Failed to enable Fail2ban."; return 1; }
    info "Fail2ban enabled -- will start automatically on boot."
}
register_action "Enable Fail2ban on Boot|fail2ban_enable|action_fail2ban_enable"
