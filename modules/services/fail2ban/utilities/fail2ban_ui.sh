#!/bin/bash
# =============================================================================
# modules/services/fail2ban/utilities/fail2ban_ui.sh
# Sourced by fail2ban.sh at startup
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================


# --- Jail selection ----------------------------------------------------------

# Present a numbered list of jails and prompt for selection
# Usage: _fail2ban_select_jail <nameref_array> <prompt>
# Sets _FAIL2BAN_SELECTED_JAIL to the chosen jail name
_fail2ban_select_jail() {
    local -n _f2b_u_jails="$1"
    local _f2b_u_prompt="${2:-Select jail}"

    if [ ${#_f2b_u_jails[@]} -eq 0 ]; then
        warn "No jails available."
        return 1
    fi

    echo ""
    local _f2b_u_count=${#_f2b_u_jails[@]}
    local _f2b_u_rows=$(( (_f2b_u_count + 2) / 3 ))
    local _f2b_u_col _f2b_u_row _f2b_u_idx _f2b_u_entry

    for (( _f2b_u_row=0; _f2b_u_row<_f2b_u_rows; _f2b_u_row++ )); do
        printf " "
        for (( _f2b_u_col=0; _f2b_u_col<3; _f2b_u_col++ )); do
            _f2b_u_idx=$(( _f2b_u_row + _f2b_u_col * _f2b_u_rows ))
            if [ $_f2b_u_idx -lt $_f2b_u_count ]; then
                _f2b_u_entry=$(printf "%d) %s" $(( _f2b_u_idx + 1 )) "${_f2b_u_jails[$_f2b_u_idx]}")
                printf "%-25.25s  " "$_f2b_u_entry"
            fi
        done
        echo ""
    done

    echo ""

    local _f2b_u_choice
    while true; do
        read -rp "  ${_f2b_u_prompt}: " _f2b_u_choice
        if [[ "$_f2b_u_choice" =~ ^[0-9]+$ ]] && \
           [ "$_f2b_u_choice" -ge 1 ] && \
           [ "$_f2b_u_choice" -le "$_f2b_u_count" ]; then
            break
        fi
        warn "Invalid selection."
    done

    _FAIL2BAN_SELECTED_JAIL="${_f2b_u_jails[$(( _f2b_u_choice - 1 ))]}"
}