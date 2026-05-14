#!/bin/bash
# =============================================================================
# modules/services/ufw/actions/ufw_deny_ip.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Action ------------------------------------------------------------------
action_ufw_deny_ip() {
    section "Deny IP"

    if ! is_ufw_installed; then
        warn "UFW is not installed."
        return 1
    fi

    # --- IP or subnet --------------------------------------------------------
    echo ""
    echo "  Deny from:"
    echo "    1)  Specific IP"
    echo "    2)  Specific subnet"
    echo ""

    local _ufw_di_from
    while true; do
        read -rp "  Selection: " _ufw_di_from_choice
        case "$_ufw_di_from_choice" in
            1)
                while true; do
                    read -rp "  IP address: " _ufw_di_from
                    if [[ "$_ufw_di_from" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
                        break
                    fi
                    warn "Invalid IP address."
                done
                break
                ;;
            2)
                while true; do
                    read -rp "  Subnet (e.g. 192.168.1.0/24): " _ufw_di_from
                    if [[ "$_ufw_di_from" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}$ ]]; then
                        break
                    fi
                    warn "Invalid subnet format."
                done
                break
                ;;
            *) warn "Invalid selection -- enter 1 or 2." ;;
        esac
    done

    # --- Destination ---------------------------------------------------------
    echo ""
    echo "  Deny to:"
    echo "    1)  Any port"
    echo "    2)  Specific port"
    echo ""

    local _ufw_di_to=""
    while true; do
        read -rp "  Selection [1]: " _ufw_di_to_choice
        _ufw_di_to_choice="${_ufw_di_to_choice:-1}"
        case "$_ufw_di_to_choice" in
            1) _ufw_di_to="" ; break ;;
            2)
                local _ufw_di_port
                while true; do
                    read -rp "  Port or service (e.g. 80, 443, ssh): " _ufw_di_port
                    if [ -z "$_ufw_di_port" ]; then
                        warn "Port cannot be empty."
                    elif [[ ! "$_ufw_di_port" =~ ^[0-9a-zA-Z]+$ ]]; then
                        warn "Invalid port or service name."
                    else
                        break
                    fi
                done
                _ufw_di_to=" to any port $_ufw_di_port"
                break
                ;;
            *) warn "Invalid selection -- enter 1 or 2." ;;
        esac
    done

    # --- Comment -------------------------------------------------------------
    echo ""
    read -rp "  Comment (optional): " _ufw_di_comment

    # --- Build and preview rule ----------------------------------------------
    local _ufw_di_rule="ufw deny from $_ufw_di_from${_ufw_di_to}"
    [ -n "$_ufw_di_comment" ] && _ufw_di_rule+=" comment '$_ufw_di_comment'"

    echo ""
    echo -e "  ${BOLD}Rule Preview:${NC}"
    echo "    $  $_ufw_di_rule"
    echo ""

    confirm_prompt "Apply this rule?" || return 1

    eval "$_ufw_di_rule" || { error "Failed to add rule."; return 1; }
    info "Rule added successfully."
}

# --- Register ----------------------------------------------------------------
register_action "Deny IP|ufw_deny_ip|action_ufw_deny_ip"