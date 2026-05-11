#!/bin/bash
# =============================================================================
# modules/services/nginx/actions/nginx_enable.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Action ------------------------------------------------------------------
action_nginx_enable() {
    section "Enable Nginx on Boot"

    if ! pkg_installed "nginx"; then
        warn "Nginx is not installed."
        return 1
    fi

    if systemctl is-enabled --quiet nginx; then
        warn "Nginx is already enabled."
        return 1
    fi

    systemctl enable nginx || { error "Failed to enable Nginx."; return 1; }

    info "Nginx enabled — will start automatically on boot."
}

# --- Register ----------------------------------------------------------------
register_action "Enable Nginx|nginx_enable|action_nginx_enable"