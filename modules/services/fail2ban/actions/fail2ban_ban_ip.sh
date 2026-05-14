#!/bin/bash
# =============================================================================
# modules/services/fail2ban/actions/fail2ban_ban_ip.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Internal: ban IP in a specific jail -------------------------------------
# Parameters:
#   $1  -- IP address to ban (required)
#   $2  -- Jail name (required)
#
# Returns:
#   0  -- Banned successfully
#   1  -- Failed or already banned
_f2b_bi_ban_in_jail() {
    local _f2b_bi_ip="$1"
    local _f2b_bi_jail="$2"

    # Check if already banned
    local -a _f2b_bi_banned=()
    fail2ban_get_jail_banned_ips "$_f2b_bi_jail" _f2b_bi_banned
    for _f2b_bi_existing in "${_f2b_bi_banned[@]}"; do
        if [ "$_f2b_bi_existing" = "$_f2b_bi_ip" ]; then
            warn "IP '$_f2b_bi_ip' is already banned in jail '$_f2b_bi_jail'."
            return 1
        fi
    done

    if fail2ban-client set "$_f2b_bi_jail" banip "$_f2b_bi_ip" 2>/dev/null; then
        info "IP '$_f2b_bi_ip' banned in jail '$_f2b_bi_jail'."
        return 0
    else
        error "Failed to ban IP '$_f2b_bi_ip' in jail '$_f2b_bi_jail'."
        return 1
    fi
}

# --- Action ------------------------------------------------------------------
action_fail2ban_ban_ip() {
    section "Ban IP"

    if ! is_fail2ban_installed; then
        warn "Fail2ban is not installed."
        return 1
    fi

    if ! is_fail2ban_running; then
        warn "Fail2ban is not running."
        return 1
    fi

    local -a _f2b_bi_active=()
    fail2ban_get_active_jails _f2b_bi_active

    if [ ${#_f2b_bi_active[@]} -eq 0 ]; then
        warn "No active jails found."
        return 1
    fi

    # --- IP address ----------------------------------------------------------
    local _f2b_bi_ip
    while true; do
        read -rp "  IP address to ban: " _f2b_bi_ip
        if [ -z "$_f2b_bi_ip" ]; then
            warn "IP address cannot be empty."
        elif [[ ! "$_f2b_bi_ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
            warn "Invalid IP address format."
        else
            break
        fi
    done

    # --- Ban scope -----------------------------------------------------------
    echo ""
    echo "  Ban from:"
    echo "    1)  Specific jail"
    echo "    2)  All active jails"
    echo ""

    local _f2b_bi_scope
    while true; do
        read -rp "  Selection: " _f2b_bi_scope
        case "$_f2b_bi_scope" in
            1|2) break ;;
            *) warn "Invalid selection -- enter 1 or 2." ;;
        esac
    done

    if [ "$_f2b_bi_scope" = "1" ]; then
        # Specific jail
        _fail2ban_select_jail _f2b_bi_active "Select jail to ban IP in" || return 1
        local _f2b_bi_jail="$_FAIL2BAN_SELECTED_JAIL"
        unset _FAIL2BAN_SELECTED_JAIL

        echo ""
        warn "This will ban the following IP:"
        echo "    IP:    $_f2b_bi_ip"
        echo "    Jail:  $_f2b_bi_jail"
        echo ""
        confirm_prompt "Are you sure?" || return 1

        _f2b_bi_ban_in_jail "$_f2b_bi_ip" "$_f2b_bi_jail"
    else
        # All jails
        echo ""
        warn "This will ban the following IP in ALL active jails:"
        echo "    IP:     $_f2b_bi_ip"
        echo "    Jails:  ${_f2b_bi_active[*]}"
        echo ""
        confirm_prompt "Are you sure?" || return 1

        for _f2b_bi_jail in "${_f2b_bi_active[@]}"; do
            _f2b_bi_ban_in_jail "$_f2b_bi_ip" "$_f2b_bi_jail"
        done
    fi
}

# --- Register ----------------------------------------------------------------
register_action "Ban IP|fail2ban_ban_ip|action_fail2ban_ban_ip"