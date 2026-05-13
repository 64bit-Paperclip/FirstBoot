#!/bin/bash
# =============================================================================
# modules/services/fail2ban/actions/fail2ban_status.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Action ------------------------------------------------------------------
action_fail2ban_status() {
    section "Fail2ban Status"

    # --- State ---------------------------------------------------------------
    if ! is_fail2ban_installed; then
        echo -e "  ${BOLD}State:${NC}        $(colorize_status "not installed")"
        section_end "Fail2ban Status"
        return 0
    elif ! is_fail2ban_running; then
        echo -e "  ${BOLD}State:${NC}        $(colorize_status "stopped")"
    else
        echo -e "  ${BOLD}State:${NC}        $(colorize_status "running")"
    fi

    echo -e "  ${BOLD}Version:${NC}      $(fail2ban-client version 2>/dev/null | head -1)"

    if systemctl is-enabled --quiet fail2ban; then
        echo -e "  ${BOLD}Boot start:${NC}   ${GREEN}enabled${NC}"
    else
        echo -e "  ${BOLD}Boot start:${NC}   ${YELLOW}disabled${NC}"
    fi

    # --- Default configuration -----------------------------------------------
    echo ""
    echo -e "  ${BOLD}Default Configuration:${NC}"
    echo ""
    local _F2B_ST_BANTIME _F2B_ST_FINDTIME _F2B_ST_MAXRETRY
    _F2B_ST_BANTIME=$(grep -A20 "^\[DEFAULT\]" /etc/fail2ban/jail.local 2>/dev/null | grep "^bantime" | head -1 | awk '{print $3}')
    _F2B_ST_FINDTIME=$(grep -A20 "^\[DEFAULT\]" /etc/fail2ban/jail.local 2>/dev/null | grep "^findtime" | head -1 | awk '{print $3}')
    _F2B_ST_MAXRETRY=$(grep -A20 "^\[DEFAULT\]" /etc/fail2ban/jail.local 2>/dev/null | grep "^maxretry" | head -1 | awk '{print $3}')
    echo "    Ban time:     ${_F2B_ST_BANTIME:-not set}"
    echo "    Find time:    ${_F2B_ST_FINDTIME:-not set}"
    echo "    Max retries:  ${_F2B_ST_MAXRETRY:-not set}"

    # --- Jail summary --------------------------------------------------------
    echo ""
    echo -e "  ${BOLD}Jails:${NC}"
    echo ""

    if ! is_fail2ban_running; then
        warn "Fail2ban is not running -- jail information unavailable."
        section_end "Fail2ban Status"
        return 0
    fi

    local -a _F2B_ST_ACTIVE=()
    fail2ban_get_active_jails _F2B_ST_ACTIVE

    if [ ${#_F2B_ST_ACTIVE[@]} -eq 0 ]; then
        echo "    No active jails."
    else
        printf "    %-25s %-10s %-10s %s\n" "Jail" "Banned" "Failed" "Ban time"
        printf "    %-25s %-10s %-10s %s\n" "-------------------------" "----------" "----------" "--------"
        for _F2B_ST_JAIL in "${_F2B_ST_ACTIVE[@]}"; do
            local _F2B_ST_BANNED _F2B_ST_FAILED _F2B_ST_BANTIME_JAIL
            _F2B_ST_BANNED=$(fail2ban_get_jail_banned "$_F2B_ST_JAIL")
            _F2B_ST_FAILED=$(fail2ban_get_jail_failed "$_F2B_ST_JAIL")
            _F2B_ST_BANTIME_JAIL=$(fail2ban-client get "$_F2B_ST_JAIL" bantime 2>/dev/null)
            printf "    %-25s %-10s %-10s %s\n" "$_F2B_ST_JAIL" "${_F2B_ST_BANNED:-0}" "${_F2B_ST_FAILED:-0}" "${_F2B_ST_BANTIME_JAIL:-default}"
        done
    fi

    section_end "Fail2ban Status"
    echo ""
    wait_for_any_key
}

# --- Register ----------------------------------------------------------------
register_action "Fail2ban Status|fail2ban_status|action_fail2ban_status"