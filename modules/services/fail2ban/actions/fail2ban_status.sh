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

    # State
    if ! is_fail2ban_installed; then
        echo -e "  ${BOLD}State:${NC}        $(colorize_status "not installed")"
        return 0
    elif ! is_fail2ban_running; then
        echo -e "  ${BOLD}State:${NC}        $(colorize_status "stopped")"
        echo -e "  ${BOLD}Version:${NC}      $(fail2ban-client version 2>/dev/null | head -1)"
        return 0
    else
        echo -e "  ${BOLD}State:${NC}        $(colorize_status "running")"
        echo -e "  ${BOLD}Version:${NC}      $(fail2ban-client version 2>/dev/null | head -1)"
    fi

    if systemctl is-enabled --quiet fail2ban; then
        echo -e "  ${BOLD}Boot start:${NC}   ${GREEN}enabled${NC}"
    else
        echo -e "  ${BOLD}Boot start:${NC}   ${YELLOW}disabled${NC}"
    fi

    # Global configuration
    echo ""
    echo -e "  ${BOLD}Configuration:${NC}"
    local _bantime  _findtime _maxretry
    _bantime=$(fail2ban-client get sshd bantime 2>/dev/null || grep -E "^bantime" /etc/fail2ban/jail.local 2>/dev/null | awk '{print $3}')
    _findtime=$(fail2ban-client get sshd findtime 2>/dev/null || grep -E "^findtime" /etc/fail2ban/jail.local 2>/dev/null | awk '{print $3}')
    _maxretry=$(fail2ban-client get sshd maxretry 2>/dev/null || grep -E "^maxretry" /etc/fail2ban/jail.local 2>/dev/null | awk '{print $3}')
    echo "    Ban time:     ${_bantime:-unknown}"
    echo "    Find time:    ${_findtime:-unknown}"
    echo "    Max retries:  ${_maxretry:-unknown}"

    # Jail summary
    echo ""
    echo -e "  ${BOLD}Jails:${NC}"
    echo ""
    local _jails
    _jails=$(fail2ban-client status 2>/dev/null | grep "Jail list" | sed 's/.*Jail list://;s/,//g')
    if [ -z "$_jails" ]; then
        echo "    No jails active."
    else
        printf "    %-20s %-10s %-10s %s\n" "Jail" "Status" "Banned" "Total failed"
        printf "    %-20s %-10s %-10s %s\n" "--------------------" "----------" "----------" "------------"
        for jail in $_jails; do
            jail=$(echo "$jail" | xargs)
            [ -z "$jail" ] && continue
            local _status _banned _failed
            _status=$(fail2ban-client status "$jail" 2>/dev/null)
            _banned=$(echo "$_status" | grep "Currently banned" | awk '{print $NF}')
            _failed=$(echo "$_status" | grep "Total failed" | awk '{print $NF}')
            local _jail_status="${GREEN}active${NC}"
            printf "    %-20s " "$jail"
            echo -ne "$_jail_status"
            printf "    %-10s %s\n" "${_banned:-0}" "${_failed:-0}"
        done
    fi

    # Recently banned IPs
    echo ""
    echo -e "  ${BOLD}Currently Banned IPs:${NC}"
    echo ""
    local _any_banned=false
    for jail in $_jails; do
        jail=$(echo "$jail" | xargs)
        [ -z "$jail" ] && continue
        local _banned_ips
        _banned_ips=$(fail2ban-client status "$jail" 2>/dev/null | grep "Banned IP list" | sed 's/.*Banned IP list://' | xargs)
        if [ -n "$_banned_ips" ]; then
            _any_banned=true
            for ip in $_banned_ips; do
                printf "    %-20s %s\n" "$ip" "[$jail]"
            done
        fi
    done
    if [ "$_any_banned" = false ]; then
        echo "    No IPs currently banned."
    fi

    echo ""

    unset _bantime _findtime _maxretry _jails _status _banned _failed _banned_ips _any_banned _jail_status
}

# --- Register ----------------------------------------------------------------
register_action "Fail2ban Status|fail2ban_status|action_fail2ban_status"