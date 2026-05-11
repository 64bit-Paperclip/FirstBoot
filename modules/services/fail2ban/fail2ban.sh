#!/bin/bash
# =============================================================================
# modules/services/fail2ban/fail2ban.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Initialize status variable ----------------------------------------------
SVC_FAIL2BAN="not installed"

# --- Source actions ----------------------------------------------------------
source_service_actions "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Menu options ------------------------------------------------------------
FAIL2BAN_MENU_OPTIONS=(
    "Status|action_fail2ban_status"
    "List Jails|action_fail2ban_list_jails"
    "List Banned IPs|action_fail2ban_list_banned"
    "---|"
    "Ban IP|action_fail2ban_ban_ip"
    "Unban IP|action_fail2ban_unban_ip"
    "---|"
    "Reload|action_fail2ban_reload"
    "Restart|action_fail2ban_restart"
)

# --- Entry function ----------------------------------------------------------
fail2ban_entry() {
    command_menu FAIL2BAN_MENU_OPTIONS "Fail2ban"
}

# --- Register ----------------------------------------------------------------
register_service "Fail2ban|fail2ban|fail2ban|SVC_FAIL2BAN|security|fail2ban_entry"