#!/bin/bash
# =============================================================================
# modules/services/ufw/actions/ufw_allow_ip.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Action ------------------------------------------------------------------
action_ufw_allow_ip() {
    section "Allow IP"

    if ! is_ufw_installed; then
        warn "UFW is not installed."
        return 1
    fi

    # --- IP or subnet --------------------------------------------------------
    echo ""
    echo "  Allow from:"
    echo "    1)  Current IP ($CURRENT_IP)"
    echo "    2)  Specific IP"
    echo "    3)  Specific subnet"
    echo ""

    local _ufw_ai_from
    while true; do
        read -rp "  Selection: " _ufw_ai_from_choice
        case "$_ufw_ai_from_choice" in
            1) _ufw_ai_from="$CURRENT_IP" ; break ;;
            2)
                while true; do
                    read -rp "  IP address: " _ufw_ai_from
                    if [[ "$_ufw_ai_from" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
                        break
                    fi
                    warn "Invalid IP address."
                done
                break
                ;;
            3)
                while true; do
                    read -rp "  Subnet (e.g. 192.168.1.0/24): " _ufw_ai_from
                    if [[ "$_ufw_ai_from" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}$ ]]; then
                        break
                    fi
                    warn "Invalid subnet format."
                done
                break
                ;;
            *) warn "Invalid selection -- enter 1, 2, or 3." ;;
        esac
    done

    # --- Destination ---------------------------------------------------------
    echo ""
    echo "  Allow to:"
    echo "    1)  Any port"
    echo "    2)  Specific port"
    echo ""

    local _ufw_ai_to=""
    while true; do
        read -rp "  Selection [1]: " _ufw_ai_to_choice
        _ufw_ai_to_choice="${_ufw_ai_to_choice:-1}"
        case "$_ufw_ai_to_choice" in
            1) _ufw_ai_to="" ; break ;;
            2)
                local _ufw_ai_port
                while true; do
                    read -rp "  Port or service (e.g. 80, 443, ssh): " _ufw_ai_port
                    if [ -z "$_ufw_ai_port" ]; then
                        warn "Port cannot be empty."
                    elif [[ ! "$_ufw_ai_port" =~ ^[0-9a-zA-Z]+$ ]]; then
                        warn "Invalid port or service name."
                    else
                        break
                    fi
                done
                _ufw_ai_to=" to any port $_ufw_ai_port"
                break
                ;;
            *) warn "Invalid selection -- enter 1 or 2." ;;
        esac
    done

    # --- Comment -------------------------------------------------------------
    echo ""
    read -rp "  Comment (optional): " _ufw_ai_comment

    # --- Build and preview rule ----------------------------------------------
    local _ufw_ai_rule="ufw allow from $_ufw_ai_from${_ufw_ai_to}"
    [ -n "$_ufw_ai_comment" ] && _ufw_ai_rule+=" comment '$_ufw_ai_comment'"

    echo ""
    echo -e "  ${BOLD}Rule Preview:${NC}"
    echo "    $  $_ufw_ai_rule"
    echo ""

    confirm_prompt "Apply this rule?" || return 1

    eval "$_ufw_ai_rule" || { error "Failed to add rule."; return 1; }
    info "Rule added successfully."
}

# --- Register ----------------------------------------------------------------
register_action "Allow IP|ufw_allow_ip|action_ufw_allow_ip"