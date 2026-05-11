#!/bin/bash
# =============================================================================
# modules/services/nginx/actions/nginx_restart.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Action ------------------------------------------------------------------
action_nginx_restart() {
    

    if ! pkg_installed "nginx"; then
        warn "Nginx is not installed."
        return 1
    fi

	section "Restarting Nginx"
    systemctl restart nginx || { error "Failed to restart Nginx."; return 1; }

    if ! systemctl is-active --quiet nginx; then
        warn "Nginx may not have restarted correctly — check: journalctl -u nginx"
        return 1
    fi

    info "Nginx restarted."
}

# --- Register ----------------------------------------------------------------
register_action "Restart Nginx|nginx_restart|action_nginx_restart"