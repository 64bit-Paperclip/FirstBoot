#!/bin/bash
# =============================================================================
# modules/services/fail2ban/actions/fail2ban_list_jails.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Action ------------------------------------------------------------------
action_fail2ban_list_jails() {
    section "Fail2ban Jails"

    if ! is_fail2ban_installed; then
        warn "Fail2ban is not installed."
        return 1
    fi

    # --- Active jails --------------------------------------------------------
    echo ""
    echo -e "  ${BOLD}Active Jails:${NC}"
    echo ""

    if ! is_fail2ban_running; then
        warn "Fail2ban is not running -- active jail information unavailable."
    else
        local _F2B_LJ_JAILS
        _F2B_LJ_JAILS=$(fail2ban-client status 2>/dev/null | grep "Jail list" | sed 's/.*Jail list://;s/,//g')

        if [ -z "$_F2B_LJ_JAILS" ]; then
            echo "    No active jails."
        else
            printf "    %-25s %-10s %-10s %s\n" "Jail" "Banned" "Failed" "Ban time"
            printf "    %-25s %-10s %-10s %s\n" "-------------------------" "----------" "----------" "--------"
            for _F2B_LJ_JAIL in $_F2B_LJ_JAILS; do
                _F2B_LJ_JAIL=$(echo "$_F2B_LJ_JAIL" | xargs)
                [ -z "$_F2B_LJ_JAIL" ] && continue
                local _F2B_LJ_STATUS _F2B_LJ_BANNED _F2B_LJ_FAILED _F2B_LJ_BANTIME
                _F2B_LJ_STATUS=$(fail2ban-client status "$_F2B_LJ_JAIL" 2>/dev/null)
                _F2B_LJ_BANNED=$(echo "$_F2B_LJ_STATUS" | grep "Currently banned" | awk '{print $NF}')
                _F2B_LJ_FAILED=$(echo "$_F2B_LJ_STATUS" | grep "Total failed" | awk '{print $NF}')
                _F2B_LJ_BANTIME=$(fail2ban-client get "$_F2B_LJ_JAIL" bantime 2>/dev/null)
                printf "    %-25s %-10s %-10s %s\n" "$_F2B_LJ_JAIL" "${_F2B_LJ_BANNED:-0}" "${_F2B_LJ_FAILED:-0}" "${_F2B_LJ_BANTIME:-default}"
            done
        fi
    fi

    # --- Configured jails from jail.d/ ---------------------------------------
    echo ""
    echo -e "  ${BOLD}Configured Jails (jail.d/):${NC}"
    echo ""

    if [ ! -d /etc/fail2ban/jail.d ] || [ -z "$(ls /etc/fail2ban/jail.d/*.conf 2>/dev/null)" ]; then
        echo "    No jails configured in jail.d/."
    else
        printf "    %-25s %-20s %s\n" "Jail" "Config File" "Status"
        printf "    %-25s %-20s %s\n" "-------------------------" "--------------------" "----------"
        for _F2B_LJ_FILE in /etc/fail2ban/jail.d/*.conf; do
            local _F2B_LJ_JAIL_NAME _F2B_LJ_ENABLED
            _F2B_LJ_JAIL_NAME=$(grep -E "^\[.+\]" "$_F2B_LJ_FILE" | head -1 | tr -d '[]')
            _F2B_LJ_ENABLED=$(grep "^enabled" "$_F2B_LJ_FILE" | awk '{print $3}')
            [ "$_F2B_LJ_JAIL_NAME" = "DEFAULT" ] && continue
            printf "    %-25s %-20s " "$_F2B_LJ_JAIL_NAME" "$(basename "$_F2B_LJ_FILE")"
            if [ "${_F2B_LJ_ENABLED:-true}" = "true" ]; then
                echo -e "${GREEN}enabled${NC}"
            else
                echo -e "${RED}disabled${NC}"
            fi
        done
    fi

    echo ""

    unset _F2B_LJ_JAILS _F2B_LJ_JAIL _F2B_LJ_STATUS _F2B_LJ_BANNED _F2B_LJ_FAILED
    unset _F2B_LJ_BANTIME _F2B_LJ_FILE _F2B_LJ_JAIL_NAME _F2B_LJ_ENABLED
}

# --- Register ----------------------------------------------------------------
register_action "List Fail2ban Jails|fail2ban_list_jails|action_fail2ban_list_jails"