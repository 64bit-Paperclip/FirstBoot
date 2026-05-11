#!/bin/bash
# =============================================================================
# modules/services/nginx/actions/nginx_stop.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Action ------------------------------------------------------------------
action_nginx_stop() {
    

    if ! pkg_installed "nginx"; then
        warn "Nginx is not installed."
        return 1
    fi

    if ! systemctl is-active --quiet nginx; then
        warn "Nginx is not running."
        return 1
    fi

	section "Stopping Nginx"
    systemctl stop nginx || { error "Failed to stop Nginx."; return 1; }

    info "Nginx stopped."
}

# --- Register ----------------------------------------------------------------
register_action "Stop Nginx|nginx_stop|action_nginx_stop"