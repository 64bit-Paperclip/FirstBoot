#!/bin/bash
# =============================================================================
# modules/services/fail2ban/actions/fail2ban_is_ip_banned.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Action ------------------------------------------------------------------
action_fail2ban_is_ip_banned() {
    

    if ! is_fail2ban_installed; then
        warn "Fail2ban is not installed."
        return 1
    fi

    if ! is_fail2ban_running; then
        warn "Fail2ban is not running."
        return 1
    fi

    section "Check Banned IP"
    local -a _f2b_iib_active=()
    fail2ban_get_active_jails _f2b_iib_active

    if [ ${#_f2b_iib_active[@]} -eq 0 ]; then
        warn "No active jails found."
        return 1
    fi

    # --- IP address ----------------------------------------------------------
    local _f2b_iib_ip
    while true; do
        read -rp "  IP address to check: " _f2b_iib_ip
        if [ -z "$_f2b_iib_ip" ]; then
            warn "IP address cannot be empty."
        elif [[ ! "$_f2b_iib_ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
            warn "Invalid IP address format."
        else
            break
        fi
    done

    # --- Check each jail -----------------------------------------------------
    echo ""
    printf "    %-25s %s\n" "Jail" "Status"
    printf "    %-25s %s\n" "-------------------------" "----------"

    local _f2b_iib_any_banned=false
    for _f2b_iib_jail in "${_f2b_iib_active[@]}"; do
        local -a _f2b_iib_banned=()
        fail2ban_get_jail_banned_ips "$_f2b_iib_jail" _f2b_iib_banned
        local _f2b_iib_found=false
        for _f2b_iib_existing in "${_f2b_iib_banned[@]}"; do
            [ "$_f2b_iib_existing" = "$_f2b_iib_ip" ] && _f2b_iib_found=true && break
        done

        printf "    %-25s " "$_f2b_iib_jail"
        if [ "$_f2b_iib_found" = true ]; then
            echo -e "${RED}banned${NC}"
            _f2b_iib_any_banned=true
        else
            echo -e "${GREEN}not banned${NC}"
        fi
    done

    echo ""
    if [ "$_f2b_iib_any_banned" = true ]; then
        warn "IP '$_f2b_iib_ip' is banned in one or more jails."
    else
        info "IP '$_f2b_iib_ip' is not banned in any jail."
    fi
    echo ""
}

# --- Register ----------------------------------------------------------------
register_action "Check if IP is Banned|fail2ban_is_ip_banned|action_fail2ban_is_ip_banned"