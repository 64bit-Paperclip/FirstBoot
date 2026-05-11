#!/bin/bash
# =============================================================================
# modules/services/ufw/ufw.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Initialize status variable ----------------------------------------------
SVC_UFW="not installed"

# --- Source actions ----------------------------------------------------------
source_service_actions "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Menu options ------------------------------------------------------------
UFW_MENU_OPTIONS=(
    "Status|action_ufw_status"
    "List Rules|action_ufw_list_rules"
    "---|"
    "Allow Port|action_ufw_allow_port"
    "Deny Port|action_ufw_deny_port"
    "Delete Rule|action_ufw_delete_rule"
    "---|"
    "Enable UFW|action_ufw_enable"
    "Disable UFW|action_ufw_disable"
    "Reset UFW|action_ufw_reset"
)

# --- Entry function ----------------------------------------------------------
ufw_entry() {
    command_menu UFW_MENU_OPTIONS "UFW Firewall"
}

# --- Register ----------------------------------------------------------------
register_service "UFW|ufw|ufw|SVC_UFW|security|ufw_entry"