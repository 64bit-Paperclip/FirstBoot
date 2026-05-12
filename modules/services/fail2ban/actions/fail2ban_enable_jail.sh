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

    if [ ! -d /etc/fail2ban/jail.d ] || [ -z "$(ls /etc/fail2ban/jail.d/*.conf 2>/dev/null)" ]; then
        warn "No jails configured in jail.d/."
        return 1
    fi

    # Build list of disabled jails
    local -a _F2B_EJ_DISABLED=()
    local -a _F2B_EJ_FILES=()

    for _F2B_EJ_FILE in /etc/fail2ban/jail.d/*.conf; do
        local _F2B_EJ_JAIL_NAME _F2B_EJ_ENABLED
        _F2B_EJ_JAIL_NAME=$(grep -E "^\[.+\]" "$_F2B_EJ_FILE" | head -1 | tr -d '[]')
        _F2B_EJ_ENABLED=$(grep "^enabled" "$_F2B_EJ_FILE" | awk '{print $3}')
        [ "$_F2B_EJ_JAIL_NAME" = "DEFAULT" ] && continue
        if [ "${_F2B_EJ_ENABLED:-true}" = "false" ]; then
            _F2B_EJ_DISABLED+=("$_F2B_EJ_JAIL_NAME")
            _F2B_EJ_FILES+=("$_F2B_EJ_FILE")
        fi
    done

    if [ ${#_F2B_EJ_DISABLED[@]} -eq 0 ]; then
        info "All configured jails are already enabled."
        return 0
    fi

    # Show disabled jails and prompt for selection
    echo ""
    local _F2B_EJ_IDX=1
    for _F2B_EJ_JAIL in "${_F2B_EJ_DISABLED[@]}"; do
        printf "    %d)  %s\n" "$_F2B_EJ_IDX" "$_F2B_EJ_JAIL"
        (( _F2B_EJ_IDX++ ))
    done
    echo ""

    local _F2B_EJ_CHOICE
    while true; do
        read -rp "  Select jail to enable: " _F2B_EJ_CHOICE
        if [[ "$_F2B_EJ_CHOICE" =~ ^[0-9]+$ ]] && \
           [ "$_F2B_EJ_CHOICE" -ge 1 ] && \
           [ "$_F2B_EJ_CHOICE" -le "${#_F2B_EJ_DISABLED[@]}" ]; then
            break
        fi
        warn "Invalid selection."
    done

    local _F2B_EJ_SELECTED_FILE="${_F2B_EJ_FILES[$(( _F2B_EJ_CHOICE - 1 ))]}"
    local _F2B_EJ_SELECTED_NAME="${_F2B_EJ_DISABLED[$(( _F2B_EJ_CHOICE - 1 ))]}"

    # Enable the jail
    sed -i 's/^enabled[[:space:]]*=.*/enabled = true/' "$_F2B_EJ_SELECTED_FILE"
    info "Jail '$_F2B_EJ_SELECTED_NAME' enabled."

    # Reload fail2ban if running
    if is_fail2ban_running; then
        fail2ban-client reload "$_F2B_EJ_SELECTED_NAME" 2>/dev/null && info "Jail reloaded."
    fi
}

# --- Register ----------------------------------------------------------------
register_action "Enable Fail2ban Jail|fail2ban_enable_jail|action_fail2ban_enable_jail"