#!/bin/bash
# =============================================================================
# modules/services/fail2ban/utilities/fail2ban_input.sh
# Sourced by fail2ban.sh at startup
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================


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
            confirm_prompt "Use this path anyway?" && break
        else
            break
        fi
    done
}