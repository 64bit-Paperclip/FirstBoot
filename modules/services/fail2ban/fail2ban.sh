#!/bin/bash
# =============================================================================
# modules/services/fail2ban/fail2ban.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Service variables -------------------------------------------------------
FAIL2BAN_LABEL="Fail2ban"
FAIL2BAN_SERVICE="fail2ban"
FAIL2BAN_PACKAGE="fail2ban"
FAIL2BAN_SVC_VAR="SVC_FAIL2BAN"
FAIL2BAN_GROUP="security"
FAIL2BAN_ENTRY="fail2ban_entry"

# --- Initialize status variable ----------------------------------------------
SVC_FAIL2BAN="not installed"

# --- Directory variables -----------------------------------------------------
FAIL2BAN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FAIL2BAN_ACTIONS_DIR="$FAIL2BAN_DIR/actions"
FAIL2BAN_UTILITIES_DIR="$FAIL2BAN_DIR/utilities"

# --- Include Utilities -------------------------------------------------------
source "$FAIL2BAN_UTILITIES_DIR/fail2ban_utilities.sh"
source "$FAIL2BAN_UTILITIES_DIR/fail2ban_input.sh"
source "$FAIL2BAN_UTILITIES_DIR/fail2ban_ui.sh"

# --- Global Utility Functions ------------------------------------------------
is_fail2ban_installed() {
    pkg_installed "$FAIL2BAN_PACKAGE"
}

is_fail2ban_running() {
    svc_running "$FAIL2BAN_SERVICE"
}

# --- Dynamic menu ------------------------------------------------------------
_fail2ban_generate_menu_options() {
    local -n _out="$1"
    _out=()

    if is_fail2ban_installed; then
        _out+=("Uninstall Fail2ban|action_fail2ban_uninstall")
    else
        _out+=("Install Fail2ban|action_fail2ban_install")
        return 0
    fi

    _out+=("---|Manage Service")

    if is_fail2ban_running; then
        _out+=("Reload|action_fail2ban_reload")
        _out+=("Restart|action_fail2ban_restart")
        _out+=("Stop|action_fail2ban_stop")
    else
        _out+=("Start|action_fail2ban_start")
    fi

    _out+=("Status|action_fail2ban_status")
    _out+=("Enable on Boot|action_fail2ban_enable")
    _out+=("Disable on Boot|action_fail2ban_disable")
    _out+=("---|Manage Jails")
    _out+=("Create Jail|action_fail2ban_create_jail_filter")
    _out+=("Delete Jail|action_fail2ban_delete_jail")
    _out+=("Disable Jail|action_fail2ban_disable_jail")
    _out+=("Enable Jail|action_fail2ban_enable_jail")
    _out+=("List Jails|action_fail2ban_list_jails")
    _out+=("---|Manage Bans")
    _out+=("Ban IP|action_fail2ban_ban_ip")
    _out+=("Is IP Banned|action_fail2ban_is_ip_banned")
    _out+=("Unban IP|action_fail2ban_unban_ip")
    _out+=("---|Manage Configurations")
    _out+=("Configure|action_fail2ban_configure")
}

# --- Entry function ----------------------------------------------------------
fail2ban_entry() {
    dynamic_command_menu _fail2ban_generate_menu_options "Fail2ban"
}

# --- Register ----------------------------------------------------------------
register_service "$FAIL2BAN_LABEL|$FAIL2BAN_SERVICE|$FAIL2BAN_PACKAGE|$FAIL2BAN_SVC_VAR|$FAIL2BAN_GROUP|$FAIL2BAN_ENTRY"

# --- Source actions ----------------------------------------------------------
source_service_actions "$FAIL2BAN_DIR"