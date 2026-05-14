#!/bin/bash
# =============================================================================
# modules/services/ufw/actions/ufw_reload.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Action ------------------------------------------------------------------
action_ufw_reload() {
    section "Reload UFW"

    if ! is_ufw_installed; then
        warn "UFW is not installed."
        return 1
    fi

    if ! ufw status 2>/dev/null | grep -q "Status: active"; then
        warn "UFW is not active."
        return 1
    fi

    ufw reload 2>/dev/null || { error "Failed to reload UFW."; return 1; }
    info "UFW reloaded."
}

# --- Register ----------------------------------------------------------------
register_action "Reload UFW|ufw_reload|action_ufw_reload"