#!/bin/bash
# =============================================================================
# modules/services/nginx/nginx.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Initialize status variable ----------------------------------------------
SVC_NGINX="not installed"

# --- Source actions ----------------------------------------------------------
source_service_actions "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Menu options ------------------------------------------------------------
NGINX_MENU_OPTIONS=(
	"Install Ngnix|action_install_nginx"
	"Uninstall Ngnix|action_install_nginx"
	"---|"
    "Status|action_nginx_status"
    "List Sites|action_nginx_list_sites"
    "---|"
    "Create Site|action_nginx_create_site"
    "Enable Site|action_nginx_enable_site"
    "Disable Site|action_nginx_disable_site"
    "Delete Site|action_nginx_delete_site"
    "---|"
    "Test Config|action_nginx_test_config"
    "Reload|action_nginx_reload"
    "Restart|action_nginx_restart"
)

# --- Entry function ----------------------------------------------------------
nginx_entry() {
    command_menu NGINX_MENU_OPTIONS "Nginx"
}

# --- Register ----------------------------------------------------------------
register_service "Nginx|nginx|nginx|SVC_NGINX|web|nginx_entry"