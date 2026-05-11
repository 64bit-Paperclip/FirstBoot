#!/bin/bash
# =============================================================================
# modules/services/nginx/actions/nginx_test_config.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Action ------------------------------------------------------------------
action_nginx_test_config() {
    

    if ! pkg_installed "nginx"; then
        warn "Nginx is not installed."
        return 1
    fi

	section "Nginx Config Test"
    
    if nginx -t 2>/dev/null; then
        info "Configuration OK"
    else
        warn "Configuration has errors:"
        nginx -t 2>&1 | sed 's/^/    /'
    fi
    
}

# --- Register ----------------------------------------------------------------
register_action "Test Nginx Config|nginx_test_config|action_nginx_test_config"