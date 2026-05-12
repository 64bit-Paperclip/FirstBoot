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

    if [ ! -d /etc/fail2ban/jail.d ] || [ -z "$(ls /etc/fail2ban/jail.d/*.conf 2>/dev/null)" ]; then
        warn "No jails configured in jail.d/."
        return 1
    fi

    

    # Build list of enabled jails
    local -a _F2B_DJ_ENABLED=()
    local -a _F2B_DJ_FILES=()

    for _F2B_DJ_FILE in /etc/fail2ban/jail.d/*.conf; do
        local _F2B_DJ_JAIL_NAME _F2B_DJ_ENABLED_VAL
        _F2B_DJ_JAIL_NAME=$(grep -E "^\[.+\]" "$_F2B_DJ_FILE" | head -1 | tr -d '[]')
        _F2B_DJ_ENABLED_VAL=$(grep "^enabled" "$_F2B_DJ_FILE" | awk '{print $3}')
        [ "$_F2B_DJ_JAIL_NAME" = "DEFAULT" ] && continue
        if [ "${_F2B_DJ_ENABLED_VAL:-true}" = "true" ]; then
            _F2B_DJ_ENABLED+=("$_F2B_DJ_JAIL_NAME")
            _F2B_DJ_FILES+=("$_F2B_DJ_FILE")
        fi
    done

    if [ ${#_F2B_DJ_ENABLED[@]} -eq 0 ]; then
        info "No enabled jails found."
        return 0
    fi

    # Show enabled jails and prompt for selection
    echo ""
    local _F2B_DJ_IDX=1
    for _F2B_DJ_JAIL in "${_F2B_DJ_ENABLED[@]}"; do
        printf "    %d)  %s\n" "$_F2B_DJ_IDX" "$_F2B_DJ_JAIL"
        (( _F2B_DJ_IDX++ ))
    done
    echo ""

    local _F2B_DJ_CHOICE
    while true; do
        read -rp "  Select jail to disable: " _F2B_DJ_CHOICE
        if [[ "$_F2B_DJ_CHOICE" =~ ^[0-9]+$ ]] && \
           [ "$_F2B_DJ_CHOICE" -ge 1 ] && \
           [ "$_F2B_DJ_CHOICE" -le "${#_F2B_DJ_ENABLED[@]}" ]; then
            break
        fi
        warn "Invalid selection."
    done

    local _F2B_DJ_SELECTED_FILE="${_F2B_DJ_FILES[$(( _F2B_DJ_CHOICE - 1 ))]}"
    local _F2B_DJ_SELECTED_NAME="${_F2B_DJ_ENABLED[$(( _F2B_DJ_CHOICE - 1 ))]}"

    # Disable the jail
    sed -i 's/^enabled[[:space:]]*=.*/enabled = false/' "$_F2B_DJ_SELECTED_FILE"
    info "Jail '$_F2B_DJ_SELECTED_NAME' disabled."

    # Reload fail2ban if running
    if is_fail2ban_running; then
        fail2ban-client reload 2>/dev/null && info "Fail2ban reloaded."
    fi
}

# --- Register ----------------------------------------------------------------
register_action "Disable Fail2ban Jail|fail2ban_disable_jail|action_fail2ban_disable_jail"