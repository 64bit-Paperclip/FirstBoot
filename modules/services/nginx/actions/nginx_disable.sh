#!/bin/bash
# =============================================================================
# modules/services/nginx/actions/nginx_disable.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Action ------------------------------------------------------------------
action_nginx_disable() {
    section "Disable Nginx on Boot"

    if ! pkg_installed "nginx"; then
        warn "Nginx is not installed."
        return 1
    fi

    if ! systemctl is-enabled --quiet nginx; then
        warn "Nginx is already disabled."
        return 1
    fi

    systemctl disable nginx || { error "Failed to disable Nginx."; return 1; }

    info "Nginx disabled — will not start automatically on boot."
}

# --- Register ----------------------------------------------------------------
register_action "Disable Nginx|nginx_disable|action_nginx_disable"