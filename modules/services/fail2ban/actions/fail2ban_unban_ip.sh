#!/bin/bash
# =============================================================================
# modules/services/fail2ban/actions/fail2ban_unban_ip.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Internal: unban IP from a specific jail ---------------------------------
# Parameters:
#   $1  -- IP address to unban (required)
#   $2  -- Jail name (required)
#
# Returns:
#   0  -- Unbanned successfully
#   1  -- Failed or not banned
_f2b_ui_unban_from_jail() {
    local _f2b_ui_ip="$1"
    local _f2b_ui_jail="$2"

    # Check if actually banned
    local -a _f2b_ui_banned=()
    fail2ban_get_jail_banned_ips "$_f2b_ui_jail" _f2b_ui_banned
    local _f2b_ui_found=false
    for _f2b_ui_existing in "${_f2b_ui_banned[@]}"; do
        [ "$_f2b_ui_existing" = "$_f2b_ui_ip" ] && _f2b_ui_found=true && break
    done

    if [ "$_f2b_ui_found" = false ]; then
        warn "IP '$_f2b_ui_ip' is not banned in jail '$_f2b_ui_jail'."
        return 1
    fi

    if fail2ban-client set "$_f2b_ui_jail" unbanip "$_f2b_ui_ip" 2>/dev/null; then
        info "IP '$_f2b_ui_ip' unbanned from jail '$_f2b_ui_jail'."
        return 0
    else
        error "Failed to unban IP '$_f2b_ui_ip' from jail '$_f2b_ui_jail'."
        return 1
    fi
}

# --- Action ------------------------------------------------------------------
action_fail2ban_unban_ip() {
    
    if ! is_fail2ban_installed; then
        warn "Fail2ban is not installed."
        return 1
    fi

    if ! is_fail2ban_running; then
        warn "Fail2ban is not running."
        return 1
    fi
    
    section "Unban IP"
    local -a _f2b_ui_active=()
    fail2ban_get_active_jails _f2b_ui_active

    if [ ${#_f2b_ui_active[@]} -eq 0 ]; then
        warn "No active jails found."
        return 1
    fi

    # --- IP address ----------------------------------------------------------
    local _f2b_ui_ip
    while true; do
        read -rp "  IP address to unban: " _f2b_ui_ip
        if [ -z "$_f2b_ui_ip" ]; then
            warn "IP address cannot be empty."
        elif [[ ! "$_f2b_ui_ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
            warn "Invalid IP address format."
        else
            break
        fi
    done

    # --- Unban scope ---------------------------------------------------------
    echo ""
    echo "  Unban from:"
    echo "    1)  Specific jail"
    echo "    2)  All jails"
    echo ""

    local _f2b_ui_scope
    while true; do
        read -rp "  Selection: " _f2b_ui_scope
        case "$_f2b_ui_scope" in
            1|2) break ;;
            *) warn "Invalid selection -- enter 1 or 2." ;;
        esac
    done

    if [ "$_f2b_ui_scope" = "1" ]; then
        # Specific jail
        _fail2ban_select_jail _f2b_ui_active "Select jail to unban IP from" || return 1
        local _f2b_ui_jail="$_FAIL2BAN_SELECTED_JAIL"
        unset _FAIL2BAN_SELECTED_JAIL

        echo ""
        warn "This will unban the following IP:"
        echo "    IP:    $_f2b_ui_ip"
        echo "    Jail:  $_f2b_ui_jail"
        echo ""
        confirm "Are you sure?" || return 1

        _f2b_ui_unban_from_jail "$_f2b_ui_ip" "$_f2b_ui_jail"
    else
        # All jails
        echo ""
        warn "This will unban the following IP from ALL active jails:"
        echo "    IP:     $_f2b_ui_ip"
        echo "    Jails:  ${_f2b_ui_active[*]}"
        echo ""
        confirm "Are you sure?" || return 1

        for _f2b_ui_jail in "${_f2b_ui_active[@]}"; do
            _f2b_ui_unban_from_jail "$_f2b_ui_ip" "$_f2b_ui_jail"
        done
    fi
}

# --- Register ----------------------------------------------------------------
register_action "Unban IP|fail2ban_unban_ip|action_fail2ban_unban_ip"