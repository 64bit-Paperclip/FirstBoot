#!/bin/bash
# =============================================================================
# modules/services/nginx/actions/nginx_start.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Action ------------------------------------------------------------------
action_nginx_start() {
    section "Starting Nginx"

    if ! pkg_installed "nginx"; then
        warn "Nginx is not installed."
        return 1
    fi

    if systemctl is-active --quiet nginx; then
        warn "Nginx is already running."
        return 1
    fi

    systemctl start nginx || { error "Failed to start Nginx."; return 1; }

    info "Nginx started."
}

# --- Register ----------------------------------------------------------------
register_action "Start Nginx|nginx_start|action_nginx_start"