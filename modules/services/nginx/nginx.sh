#!/bin/bash
# =============================================================================
# modules/services/nginx/nginx.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Initialize status variable ----------------------------------------------
SVC_NGINX="not installed"
NGINX_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NGINX_ACTIONS_DIR="$NGINX_DIR/actions"
NGINX_UTILS_DIR="$NGINX_DIR/utilities"

source "$NGINX_UTILS_DIR/nginx_blocks.sh"



# --- Source actions ----------------------------------------------------------
source_service_actions "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Menu options ------------------------------------------------------------
NGINX_MENU_OPTIONS=(
	"Install Ngnix|action_install_nginx"
	"Uninstall Ngnix|action_install_nginx"
	"---|"
	"Reload|action_nginx_reload"
    "Restart|action_nginx_restart"
    "Status|action_nginx_status"
	"Test Configuration|action_nginx_test_config"
    "---|"
    "Create Site|action_nginx_create_site"
	"Delete Site|action_nginx_delete_site"
	"Disable Site|action_nginx_disable_site"
	"Disable All Sites|action_nginx_disable_all_sites"
    "Enable Site|action_nginx_enable_site"
	"List Sites|action_nginx_list_sites"
)

# --- Entry function ----------------------------------------------------------
nginx_entry() {
    command_menu NGINX_MENU_OPTIONS "Nginx"
}

# --- Register ----------------------------------------------------------------
register_service "Nginx|nginx|nginx|SVC_NGINX|web|nginx_entry"