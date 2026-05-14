#!/bin/bash
# =============================================================================
# modules/services/ufw/actions/ufw_enable.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Action ------------------------------------------------------------------
action_ufw_enable() {
    section "Enable UFW"

    if ! is_ufw_installed; then
        warn "UFW is not installed."
        return 1
    fi

    if ufw status 2>/dev/null | grep -q "Status: active"; then
        warn "UFW is already active."
        return 1
    fi

    confirm "Enable UFW? This will activate all configured rules." || return 1

    echo "y" | ufw enable 2>/dev/null || { error "Failed to enable UFW."; return 1; }
    info "UFW enabled."
}

# --- Register ----------------------------------------------------------------
register_action "Enable UFW|ufw_enable|action_ufw_enable"