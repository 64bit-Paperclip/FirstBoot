#!/bin/bash
# =============================================================================
# modules/services/nginx/nginx.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Service variables -------------------------------------------------------
NGINX_LABEL="Nginx"
NGINX_SERVICE="nginx"
NGINX_PACKAGE="nginx"
NGINX_SVC_VAR="SVC_NGINX"
NGINX_GROUP="web"
NGINX_ENTRY="nginx_entry"

# --- Initialize status variable ----------------------------------------------
SVC_NGINX="not installed"

# --- Directory variables -----------------------------------------------------
NGINX_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NGINX_ACTIONS_DIR="$NGINX_DIR/actions"
NGINX_UTILS_DIR="$NGINX_DIR/utilities"

# --- Include Utilities -------------------------------------------------------
source "$NGINX_UTILS_DIR/nginx_blocks.sh"

# --- Global Utility Functions ------------------------------------------------
is_nginx_installed(){
    pkg_installed "$NGINX_PACKAGE"
}

is_nginx_running(){
    svc_running "$NGINX_SERVICE"
}

# --- Entry function ----------------------------------------------------------
nginx_entry() {
    dynamic_command_menu _nginx_generate_menu_options "Nginx"
    
}

# --- Register ----------------------------------------------------------------
register_service "$NGINX_LABEL|$NGINX_SERVICE|$NGINX_PACKAGE|$NGINX_SVC_VAR|$NGINX_GROUP|$NGINX_ENTRY"

# --- Source actions ----------------------------------------------------------
source_service_actions "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"


_nginx_generate_menu_options() {
    local -n _out="$1"
    _out=()

    if is_nginx_installed; then
        _out+=("Uninstall Nginx|action_nginx_uninstall")
        _out+=("---|")
    else
        _out+=("Install Nginx|action_nginx_install")
        return 0
    fi


    if is_nginx_running; then
        _out+=("Stop|action_nginx_stop")
        _out+=("Restart|action_nginx_restart")
        _out+=("Reload|action_nginx_reload")
    else
        _out+=("Start|action_nginx_start")
    fi
    _out+=("Status|action_nginx_status")
    _out+=("Enable on Boot|action_nginx_enable")
    _out+=("Disable on Boot|action_nginx_disable")
    _out+=("---|")
    _out+=("Create Site|action_nginx_create_site")
    _out+=("Disable Site|action_nginx_disable_site")
    _out+=("Delete Site|action_nginx_delete_site")
    _out+=("Enable Site|action_nginx_enable_site")
    _out+=("List Sites|action_nginx_list_sites")
    _out+=("Test Configuration|action_nginx_test_config")
}


