#!/bin/bash
# =============================================================================
# modules/services/fail2ban/actions/fail2ban_delete_jail.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Action ------------------------------------------------------------------
action_fail2ban_delete_jail() {
    section "Delete Fail2ban Jail"

    if ! is_fail2ban_installed; then
        warn "Fail2ban is not installed."
        return 1
    fi

    local -a _f2b_dj_jails=()
    _fail2ban_get_jail_names _f2b_dj_jails

    if [ ${#_f2b_dj_jails[@]} -eq 0 ]; then
        warn "No jails configured in jail.d/."
        return 1
    fi

    _fail2ban_select_jail _f2b_dj_jails "Select jail to delete" || return 1
    local _f2b_dj_selected="$_FAIL2BAN_SELECTED_JAIL"
    unset _FAIL2BAN_SELECTED_JAIL

    local _f2b_dj_file
    _f2b_dj_file=$(_fail2ban_get_jail_file "$_f2b_dj_selected")

    echo ""
    warn "This will permanently delete the jail configuration:"
    echo "    Jail:   $_f2b_dj_selected"
    echo "    File:   $_f2b_dj_file"
    echo ""

    confirm_prompt "Are you sure?" || return 1

    # Stop the jail in fail2ban if running
    if is_fail2ban_running; then
        fail2ban-client stop "$_f2b_dj_selected" 2>/dev/null
    fi

    rm -f "$_f2b_dj_file" || { error "Failed to delete jail file."; return 1; }
    info "Jail '$_f2b_dj_selected' deleted."

    # Reload fail2ban if running
    if is_fail2ban_running; then
        fail2ban-client reload 2>/dev/null && info "Fail2ban reloaded."
    fi
}

# --- Register ----------------------------------------------------------------
register_action "Delete Fail2ban Jail|fail2ban_delete_jail|action_fail2ban_delete_jail"