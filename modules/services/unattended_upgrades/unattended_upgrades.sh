#!/bin/bash
# =============================================================================
# modules/services/unattended/unattended.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Service variables -------------------------------------------------------
UNATTENDED_LABEL="Unattended Upgrades"
UNATTENDED_SERVICE="unattended-upgrades"
UNATTENDED_PACKAGE="unattended-upgrades"
UNATTENDED_SVC_VAR="SVC_UNATTENDED"
UNATTENDED_GROUP="security"
UNATTENDED_ENTRY="unattended_upgrades_entry"

# --- Initialize status variable ----------------------------------------------
SVC_UNATTENDED="not installed"

# --- Directory variables -----------------------------------------------------
UNATTENDED_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UNATTENDED_ACTIONS_DIR="$UNATTENDED_DIR/actions"

# --- Global Utility Functions ------------------------------------------------
is_unattended_upgrades_installed() {
    pkg_installed "$UNATTENDED_PACKAGE"
}

is_unattended_upgrades_running() {
    svc_running "$UNATTENDED_SERVICE"
}

# --- Dynamic menu ------------------------------------------------------------
_unattended_upgrades_generate_menu_options() {
    local -n _out="$1"
    _out=()

    if is_unattended_installed; then
        _out+=("Uninstall|action_unattended_uninstall")
    else
        _out+=("Install|action_unattended_install")
        return 0
    fi

    _out+=("---|")

    _out+=("Status|action_unattended_status")
    _out+=("Enable on Boot|action_unattended_enable")
    _out+=("Disable on Boot|action_unattended_disable")
    _out+=("---|")
    _out+=("Configure|action_unattended_configure")
    _out+=("Run Now|action_unattended_run_now")
    _out+=("View Log|action_unattended_view_log")
}

# --- Entry function ----------------------------------------------------------
unattended_upgrades_entry() {
    dynamic_command_menu _unattended_upgrades_generate_menu_options "Unattended Upgrades"
}

# --- Register ----------------------------------------------------------------
register_service "$UNATTENDED_LABEL|$UNATTENDED_SERVICE|$UNATTENDED_PACKAGE|$UNATTENDED_SVC_VAR|$UNATTENDED_GROUP|$UNATTENDED_ENTRY"

# --- Source actions ----------------------------------------------------------
source_service_actions "$UNATTENDED_DIR"