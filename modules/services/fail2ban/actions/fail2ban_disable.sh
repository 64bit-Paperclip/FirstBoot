

#!/bin/bash
# =============================================================================
# modules/services/fail2ban/actions/fail2ban_disable.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Disable on boot ---------------------------------------------------------
action_fail2ban_disable() {
    if ! is_fail2ban_installed; then
        warn "Fail2ban is not installed."
        return 1
    fi
    
    if ! systemctl is-enabled --quiet fail2ban; then
        warn "Fail2ban is already disabled."
        return 1
    fi
    systemctl disable fail2ban || { error "Failed to disable Fail2ban."; return 1; }
    info "Fail2ban disabled -- will not start automatically on boot."
}
register_action "Disable Fail2ban on Boot|fail2ban_disable|action_fail2ban_disable"