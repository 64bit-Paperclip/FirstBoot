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
#   jail file operations, jail selection, and active jail queries so action
#   scripts don't duplicate logic.
#
# Naming conventions:
#   _fail2ban_get_*    -- retrieves data, outputs to stdout or nameref
#   _fail2ban_select_* -- presents a selection prompt, returns chosen value
# =============================================================================

# --- Jail file helpers -------------------------------------------------------

# Get all jail names from jail.d/
# Usage: _fail2ban_get_jail_names <nameref>
_fail2ban_get_jail_names() {
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
# Usage: _fail2ban_get_enabled_jails <nameref>
_fail2ban_get_enabled_jails() {
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
# Usage: _fail2ban_get_disabled_jails <nameref>
_fail2ban_get_disabled_jails() {
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
# Usage: _fail2ban_get_jail_file <jail_name>
# Outputs file path to stdout
_fail2ban_get_jail_file() {
    local _F2B_U_JAIL_NAME="$1"
    echo "/etc/fail2ban/jail.d/${_F2B_U_JAIL_NAME}.conf"
}

# --- Jail selection ----------------------------------------------------------

# Present a numbered list of jails and prompt for selection
# Usage: _fail2ban_select_jail <nameref_array> <prompt>
# Sets _FAIL2BAN_SELECTED_JAIL to the chosen jail name
_fail2ban_select_jail() {
    local -n _F2B_U_JAILS="$1"
    local _F2B_U_PROMPT="${2:-Select jail}"

    if [ ${#_F2B_U_JAILS[@]} -eq 0 ]; then
        warn "No jails available."
        return 1
    fi

    echo ""
    local _F2B_U_IDX=1
    for _F2B_U_JAIL in "${_F2B_U_JAILS[@]}"; do
        printf "    %d)  %s\n" "$_F2B_U_IDX" "$_F2B_U_JAIL"
        (( _F2B_U_IDX++ ))
    done
    echo ""

    local _F2B_U_CHOICE
    while true; do
        read -rp "  ${_F2B_U_PROMPT}: " _F2B_U_CHOICE
        if [[ "$_F2B_U_CHOICE" =~ ^[0-9]+$ ]] && \
           [ "$_F2B_U_CHOICE" -ge 1 ] && \
           [ "$_F2B_U_CHOICE" -le "${#_F2B_U_JAILS[@]}" ]; then
            break
        fi
        warn "Invalid selection."
    done

    _FAIL2BAN_SELECTED_JAIL="${_F2B_U_JAILS[$(( _F2B_U_CHOICE - 1 ))]}"
}

# --- Active jail queries -----------------------------------------------------

# Get list of currently active jails from fail2ban-client
# Usage: _fail2ban_get_active_jails <nameref>
_fail2ban_get_active_jails() {
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
# Usage: _fail2ban_get_jail_banned <jail_name>
# Outputs count to stdout
_fail2ban_get_jail_banned() {
    local _F2B_U_JAIL="$1"
    fail2ban-client status "$_F2B_U_JAIL" 2>/dev/null | grep "Currently banned" | awk '{print $NF}'
}

# Get total failed count for a jail
# Usage: _fail2ban_get_jail_failed <jail_name>
# Outputs count to stdout
_fail2ban_get_jail_failed() {
    local _F2B_U_JAIL="$1"
    fail2ban-client status "$_F2B_U_JAIL" 2>/dev/null | grep "Total failed" | awk '{print $NF}'
}

# Get list of banned IPs for a jail
# Usage: _fail2ban_get_jail_banned_ips <jail_name> <nameref>
_fail2ban_get_jail_banned_ips() {
    local _F2B_U_JAIL="$1"
    local -n _out="$2"
    _out=()
    local _F2B_U_IPS
    _F2B_U_IPS=$(fail2ban-client status "$_F2B_U_JAIL" 2>/dev/null | grep "Banned IP list" | sed 's/.*Banned IP list://' | xargs)
    for _F2B_U_IP in $_F2B_U_IPS; do
        [ -n "$_F2B_U_IP" ] && _out+=("$_F2B_U_IP")
    done
}




# Collect and validate ban time
# Usage: _fail2ban_collect_bantime <varname>
_fail2ban_collect_bantime() {
    local -n _out="$1"
    while true; do
        read -rp "  Ban time (e.g. 10m, 1h, 1d) [1h]: " _out
        _out="${_out:-1h}"
        if [[ "$_out" =~ ^[0-9]+(s|m|h|d|w)$ ]]; then
            break
        fi
        warn "Invalid format. Use a number followed by s, m, h, d, or w (e.g. 10m, 1h, 7d)."
    done
}

# Collect and validate find time
# Usage: _fail2ban_collect_findtime <varname>
_fail2ban_collect_findtime() {
    local -n _out="$1"
    while true; do
        read -rp "  Find time (e.g. 10m, 1h) [10m]: " _out
        _out="${_out:-10m}"
        if [[ "$_out" =~ ^[0-9]+(s|m|h|d|w)$ ]]; then
            break
        fi
        warn "Invalid format. Use a number followed by s, m, h, d, or w (e.g. 10m, 1h)."
    done
}

# Collect and validate max retries
# Usage: _fail2ban_collect_maxretry <varname>
_fail2ban_collect_maxretry() {
    local -n _out="$1"
    while true; do
        read -rp "  Max retries [5]: " _out
        _out="${_out:-5}"
        if [[ "$_out" =~ ^[0-9]+$ ]] && [ "$_out" -gt 0 ]; then
            break
        fi
        warn "Invalid value. Must be a positive number."
    done
}

# Collect and validate port(s)
# Usage: _fail2ban_collect_port <varname>
_fail2ban_collect_port() {
    local -n _out="$1"
    while true; do
        read -rp "  Port(s) to watch (e.g. ssh, http, 80, 80,443) [ssh]: " _out
        _out="${_out:-ssh}"
        if [[ "$_out" =~ ^[a-z0-9,]+$ ]]; then
            break
        fi
        warn "Invalid format. Use service names or port numbers separated by commas."
    done
}

# Collect and validate log path
# Usage: _fail2ban_collect_logpath <varname>
_fail2ban_collect_logpath() {
    local -n _out="$1"
    while true; do
        read -rp "  Log path (e.g. /var/log/auth.log): " _out
        if [ -z "$_out" ]; then
            warn "Log path cannot be empty."
        elif [ ! -f "$_out" ]; then
            warn "File '$_out' does not exist."
            confirm "Use this path anyway?" && break
        else
            break
        fi
    done
}