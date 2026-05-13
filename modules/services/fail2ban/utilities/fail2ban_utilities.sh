#!/bin/bash
# =============================================================================
# modules/services/fail2ban/utilities/fail2ban_utilities.sh
# Sourced by fail2ban.sh at startup
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
#
# Purpose:
#   Shared helper functions for fail2ban action scripts. Provides reusable
#   jail file operations and active jail queries so action
#   scripts don't duplicate logic.
#
# Naming conventions:
#   fail2ban_get_*    -- retrieves data, outputs to stdout or nameref
# =============================================================================

# --- Jail file helpers -------------------------------------------------------

# Get all jail names from jail.d/
# Usage: fail2ban_get_jail_names <nameref>
fail2ban_get_jail_names() {
    local -n _out="$1"
    _out=()
    [ ! -d /etc/fail2ban/jail.d ] && return 0
    for _F2B_U_FILE in /etc/fail2ban/jail.d/*.conf; do
        [ -f "$_F2B_U_FILE" ] || continue
        local _F2B_U_NAME
        _F2B_U_NAME=$(grep -E "^\[.+\]" "$_F2B_U_FILE" | head -1 | tr -d '[]')
        [ "$_F2B_U_NAME" = "DEFAULT" ] && continue
        [ -n "$_F2B_U_NAME" ] && _out+=("$_F2B_U_NAME")
    done
}

# Get only enabled jail names from jail.d/
# Usage: fail2ban_get_enabled_jails <nameref>
fail2ban_get_enabled_jails() {
    local -n _out="$1"
    _out=()
    [ ! -d /etc/fail2ban/jail.d ] && return 0
    for _F2B_U_FILE in /etc/fail2ban/jail.d/*.conf; do
        [ -f "$_F2B_U_FILE" ] || continue
        local _F2B_U_NAME _F2B_U_ENABLED
        _F2B_U_NAME=$(grep -E "^\[.+\]" "$_F2B_U_FILE" | head -1 | tr -d '[]')
        _F2B_U_ENABLED=$(grep "^enabled" "$_F2B_U_FILE" | awk '{print $3}')
        [ "$_F2B_U_NAME" = "DEFAULT" ] && continue
        [ "${_F2B_U_ENABLED:-true}" = "true" ] && _out+=("$_F2B_U_NAME")
    done
}

# Get only disabled jail names from jail.d/
# Usage: fail2ban_get_disabled_jails <nameref>
fail2ban_get_disabled_jails() {
    local -n _out="$1"
    _out=()
    [ ! -d /etc/fail2ban/jail.d ] && return 0
    for _F2B_U_FILE in /etc/fail2ban/jail.d/*.conf; do
        [ -f "$_F2B_U_FILE" ] || continue
        local _F2B_U_NAME _F2B_U_ENABLED
        _F2B_U_NAME=$(grep -E "^\[.+\]" "$_F2B_U_FILE" | head -1 | tr -d '[]')
        _F2B_U_ENABLED=$(grep "^enabled" "$_F2B_U_FILE" | awk '{print $3}')
        [ "$_F2B_U_NAME" = "DEFAULT" ] && continue
        [ "${_F2B_U_ENABLED:-true}" = "false" ] && _out+=("$_F2B_U_NAME")
    done
}

# Get the jail.d/ file path for a given jail name
# Usage: fail2ban_get_jail_file <jail_name>
# Outputs file path to stdout
fail2ban_get_jail_file() {
    local _F2B_U_JAIL_NAME="$1"
    echo "/etc/fail2ban/jail.d/${_F2B_U_JAIL_NAME}.conf"
}


# --- Active jail queries -----------------------------------------------------

# Get list of currently active jails from fail2ban-client
# Usage: fail2ban_get_active_jails <nameref>
fail2ban_get_active_jails() {
    local -n _out="$1"
    _out=()
    local _F2B_U_RAW
    _F2B_U_RAW=$(fail2ban-client status 2>/dev/null | grep "Jail list" | sed 's/.*Jail list://;s/,//g')
    for _F2B_U_JAIL in $_F2B_U_RAW; do
        _F2B_U_JAIL=$(echo "$_F2B_U_JAIL" | xargs)
        [ -n "$_F2B_U_JAIL" ] && _out+=("$_F2B_U_JAIL")
    done
}

# Get currently banned IP count for a jail
# Usage: fail2ban_get_jail_banned <jail_name>
# Outputs count to stdout
fail2ban_get_jail_banned() {
    local _F2B_U_JAIL="$1"
    fail2ban-client status "$_F2B_U_JAIL" 2>/dev/null | grep "Currently banned" | awk '{print $NF}'
}

# Get total failed count for a jail
# Usage: _fail2ban_get_jail_failed <jail_name>
# Outputs count to stdout
fail2ban_get_jail_failed() {
    local _F2B_U_JAIL="$1"
    fail2ban-client status "$_F2B_U_JAIL" 2>/dev/null | grep "Total failed" | awk '{print $NF}'
}

# Get list of banned IPs for a jail
# Usage: fail2ban_get_jail_banned_ips <jail_name> <nameref>
fail2ban_get_jail_banned_ips() {
    local _F2B_U_JAIL="$1"
    local -n _out="$2"
    _out=()
    local _F2B_U_IPS
    _F2B_U_IPS=$(fail2ban-client status "$_F2B_U_JAIL" 2>/dev/null | grep "Banned IP list" | sed 's/.*Banned IP list://' | xargs)
    for _F2B_U_IP in $_F2B_U_IPS; do
        [ -n "$_F2B_U_IP" ] && _out+=("$_F2B_U_IP")
    done
}

