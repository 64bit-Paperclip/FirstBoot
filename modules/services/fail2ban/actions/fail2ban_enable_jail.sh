#!/bin/bash
# =============================================================================
# modules/services/fail2ban/actions/fail2ban_enable_jail.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Action ------------------------------------------------------------------
action_fail2ban_enable_jail() {
    section "Enable Fail2ban Jail"

    if ! is_fail2ban_installed; then
        warn "Fail2ban is not installed."
        return 1
    fi

    local -a _F2B_EJ_DISABLED=()
    _fail2ban_get_disabled_jails _F2B_EJ_DISABLED

    if [ ${#_F2B_EJ_DISABLED[@]} -eq 0 ]; then
        info "No disabled jails found."
        return 0
    fi

    _fail2ban_select_jail _F2B_EJ_DISABLED "Select jail to enable" || return 1

    local _F2B_EJ_FILE
    _F2B_EJ_FILE=$(_fail2ban_get_jail_file "$_FAIL2BAN_SELECTED_JAIL")

    sed -i 's/^enabled[[:space:]]*=.*/enabled = true/' "$_F2B_EJ_FILE"
    info "Jail '$_FAIL2BAN_SELECTED_JAIL' enabled."

    if is_fail2ban_running; then
        fail2ban-client reload "$_FAIL2BAN_SELECTED_JAIL" 2>/dev/null && info "Jail reloaded."
    fi

    unset _FAIL2BAN_SELECTED_JAIL
}

# --- Register ----------------------------------------------------------------
register_action "Enable Fail2ban Jail|fail2ban_enable_jail|action_fail2ban_enable_jail"