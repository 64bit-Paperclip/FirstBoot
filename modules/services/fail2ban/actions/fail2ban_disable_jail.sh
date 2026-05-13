#!/bin/bash
# =============================================================================
# modules/services/fail2ban/actions/fail2ban_disable_jail.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Action ------------------------------------------------------------------
action_fail2ban_disable_jail() {
    section "Disable Fail2ban Jail"

    if ! is_fail2ban_installed; then
        warn "Fail2ban is not installed."
        return 1
    fi

    local -a _F2B_DJ_ENABLED=()
    fail2ban_get_enabled_jails _F2B_DJ_ENABLED

    if [ ${#_F2B_DJ_ENABLED[@]} -eq 0 ]; then
        info "No enabled jails found."
        return 0
    fi

    _fail2ban_select_jail _F2B_DJ_ENABLED "Select jail to disable" || return 1

    local _F2B_DJ_FILE
    _F2B_DJ_FILE=$(fail2ban_get_jail_file "$_FAIL2BAN_SELECTED_JAIL")

    sed -i 's/^enabled[[:space:]]*=.*/enabled = false/' "$_F2B_DJ_FILE"
    info "Jail '$_FAIL2BAN_SELECTED_JAIL' disabled."

    if is_fail2ban_running; then
        fail2ban-client stop "$_FAIL2BAN_SELECTED_JAIL" 2>/dev/null && info "Jail stopped."
        fail2ban-client reload 2>/dev/null && info "Fail2ban reloaded."
    fi

    unset _FAIL2BAN_SELECTED_JAIL
}

# --- Register ----------------------------------------------------------------
register_action "Disable Fail2ban Jail|fail2ban_disable_jail|action_fail2ban_disable_jail"