#!/bin/bash
# =============================================================================
# modules/services/nginx/nginx.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Source actions ----------------------------------------------------------
NGINX_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for _file in "$NGINX_DIR/actions"/*.sh; do
    [ -f "$_file" ] && source "$_file"
done
unset _file NGINX_DIR

# --- Entry function ----------------------------------------------------------
nginx_entry() {
    # TODO: not yet implemented
    warn "Nginx service not yet implemented"
}

# --- Register ----------------------------------------------------------------
register_service "Nginx|nginx|nginx|SVC_NGINX|web|nginx_entry"