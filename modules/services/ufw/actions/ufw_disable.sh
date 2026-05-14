#!/bin/bash
# =============================================================================
# modules/services/ufw/actions/ufw_disable.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Action ------------------------------------------------------------------
action_ufw_disable() {
    section "Disable UFW"

    if ! is_ufw_installed; then
        warn "UFW is not installed."
        return 1
    fi

    if ! ufw status 2>/dev/null | grep -q "Status: active"; then
        warn "UFW is already inactive."
        return 1
    fi

    warn "Disabling UFW will stop all firewall protection."
    confirm_prompt "Are you sure you want to disable UFW?" || return 1

    ufw disable 2>/dev/null || { error "Failed to disable UFW."; return 1; }
    info "UFW disabled."
}

# --- Register ----------------------------------------------------------------
register_action "Disable UFW|ufw_disable|action_ufw_disable"