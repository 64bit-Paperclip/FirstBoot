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
        local -a _F2B_LJ_ACTIVE=()
        _fail2ban_get_active_jails _F2B_LJ_ACTIVE

        if [ ${#_F2B_LJ_ACTIVE[@]} -eq 0 ]; then
            echo "    No active jails."
        else
            printf "    %-25s %-10s %-10s %s\n" "Jail" "Banned" "Failed" "Ban time"
            printf "    %-25s %-10s %-10s %s\n" "-------------------------" "----------" "----------" "--------"
            for _F2B_LJ_JAIL in "${_F2B_LJ_ACTIVE[@]}"; do
                local _F2B_LJ_BANNED _F2B_LJ_FAILED _F2B_LJ_BANTIME
                _F2B_LJ_BANNED=$(_fail2ban_get_jail_banned "$_F2B_LJ_JAIL")
                _F2B_LJ_FAILED=$(_fail2ban_get_jail_failed "$_F2B_LJ_JAIL")
                _F2B_LJ_BANTIME=$(fail2ban-client get "$_F2B_LJ_JAIL" bantime 2>/dev/null)
                printf "    %-25s %-10s %-10s %s\n" "$_F2B_LJ_JAIL" "${_F2B_LJ_BANNED:-0}" "${_F2B_LJ_FAILED:-0}" "${_F2B_LJ_BANTIME:-default}"
            done
        fi
    fi

    # --- Configured jails from jail.d/ ---------------------------------------
    echo ""
    echo -e "  ${BOLD}Configured Jails (jail.d/):${NC}"
    echo ""

    local -a _F2B_LJ_ALL=()
    _fail2ban_get_jail_names _F2B_LJ_ALL

    if [ ${#_F2B_LJ_ALL[@]} -eq 0 ]; then
        echo "    No jails configured in jail.d/."
    else
        printf "    %-25s %-20s %s\n" "Jail" "Config File" "Status"
        printf "    %-25s %-20s %s\n" "-------------------------" "--------------------" "----------"
        for _F2B_LJ_JAIL in "${_F2B_LJ_ALL[@]}"; do
            local _F2B_LJ_FILE _F2B_LJ_ENABLED
            _F2B_LJ_FILE=$(_fail2ban_get_jail_file "$_F2B_LJ_JAIL")
            _F2B_LJ_ENABLED=$(grep "^enabled" "$_F2B_LJ_FILE" 2>/dev/null | awk '{print $3}')
            printf "    %-25s %-20s " "$_F2B_LJ_JAIL" "$(basename "$_F2B_LJ_FILE")"
            if [ "${_F2B_LJ_ENABLED:-true}" = "true" ]; then
                echo -e "${GREEN}enabled${NC}"
            else
                echo -e "${RED}disabled${NC}"
            fi
        done
    fi

    echo ""
}

# --- Register ----------------------------------------------------------------
register_action "List Fail2ban Jails|fail2ban_list_jails|action_fail2ban_list_jails"