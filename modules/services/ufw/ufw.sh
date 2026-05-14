#!/bin/bash
# =============================================================================
# modules/services/ufw/ufw.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Service variables -------------------------------------------------------
UFW_LABEL="UFW"
UFW_SERVICE="ufw"
UFW_PACKAGE="ufw"
UFW_SVC_VAR="SVC_UFW"
UFW_GROUP="security"
UFW_ENTRY="ufw_entry"

# --- Initialize status variable ----------------------------------------------
SVC_UFW="not installed"

# --- Directory variables -----------------------------------------------------
UFW_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UFW_ACTIONS_DIR="$UFW_DIR/actions"

# --- Global Utility Functions ------------------------------------------------
is_ufw_installed() {
    pkg_installed "$UFW_PACKAGE"
}

is_ufw_running() {
    svc_running "$UFW_SERVICE"
}

_ufw_generate_menu_options() {
    local -n _out="$1"
    _out=()



    _out+=("---|")

    if ufw status 2>/dev/null | grep -q "Status: active"; then
        _out+=("Disable UFW|action_ufw_disable")
    else
        _out+=("Enable UFW|action_ufw_enable")
    fi

    _out+=("Status|action_ufw_status")
    _out+=("Reload UFW|action_ufw_reload")
    _out+=("---|")
    _out+=("List Rules|action_ufw_list_rules")
    _out+=("Allow Port|action_ufw_allow_port")
    _out+=("Deny Port|action_ufw_deny_port")
    _out+=("Allow IP|action_ufw_allow_ip")
    _out+=("Deny IP|action_ufw_deny_ip")
    _out+=("Delete Rule|action_ufw_delete_rule")
}

# --- Entry function ----------------------------------------------------------
ufw_entry() {
    dynamic_command_menu _ufw_generate_menu_options "UFW Firewall"
}

# --- Register ----------------------------------------------------------------
register_service "$UFW_LABEL|$UFW_SERVICE|$UFW_PACKAGE|$UFW_SVC_VAR|$UFW_GROUP|$UFW_ENTRY"

# --- Source actions ----------------------------------------------------------
source_service_actions "$UFW_DIR"