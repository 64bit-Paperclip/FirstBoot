#!/bin/bash
# =============================================================================
# modules/services/ufw/actions/ufw_allow_port.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Action ------------------------------------------------------------------
action_ufw_allow_port() {
    section "Allow Port"

    if ! is_ufw_installed; then
        warn "UFW is not installed."
        return 1
    fi

    # --- Port ----------------------------------------------------------------
    local _ufw_ap_port
    while true; do
        read -rp "  Port or service (e.g. 80, 443, ssh, http): " _ufw_ap_port
        if [ -z "$_ufw_ap_port" ]; then
            warn "Port cannot be empty."
        elif [[ ! "$_ufw_ap_port" =~ ^[0-9a-zA-Z]+$ ]]; then
            warn "Invalid port or service name."
        else
            break
        fi
    done

    # --- Protocol ------------------------------------------------------------
    echo ""
    echo "  Protocol:"
    echo "    1)  Any (tcp and udp)"
    echo "    2)  TCP only"
    echo "    3)  UDP only"
    echo ""

    local _ufw_ap_proto=""
    while true; do
        read -rp "  Selection [1]: " _ufw_ap_proto_choice
        _ufw_ap_proto_choice="${_ufw_ap_proto_choice:-1}"
        case "$_ufw_ap_proto_choice" in
            1) _ufw_ap_proto=""    ; break ;;
            2) _ufw_ap_proto="/tcp"; break ;;
            3) _ufw_ap_proto="/udp"; break ;;
            *) warn "Invalid selection -- enter 1, 2, or 3." ;;
        esac
    done

    # --- Source IP -----------------------------------------------------------
    echo ""
    echo "  Allow from:"
    echo "    1)  Anywhere"
    echo "    2)  Current IP ($CURRENT_IP)"
    echo "    3)  Specific IP"
    echo "    4)  Specific subnet"
    echo ""

    local _ufw_ap_from=""
    while true; do
        read -rp "  Selection [1]: " _ufw_ap_from_choice
        _ufw_ap_from_choice="${_ufw_ap_from_choice:-1}"
        case "$_ufw_ap_from_choice" in
            1) _ufw_ap_from=""             ; break ;;
            2) _ufw_ap_from="$CURRENT_IP"  ; break ;;
            3)
                while true; do
                    read -rp "  IP address: " _ufw_ap_from
                    if [[ "$_ufw_ap_from" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
                        break
                    fi
                    warn "Invalid IP address."
                done
                break
                ;;
            4)
                while true; do
                    read -rp "  Subnet (e.g. 192.168.1.0/24): " _ufw_ap_from
                    if [[ "$_ufw_ap_from" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}$ ]]; then
                        break
                    fi
                    warn "Invalid subnet format."
                done
                break
                ;;
            *) warn "Invalid selection -- enter 1, 2, 3, or 4." ;;
        esac
    done

    # --- Comment -------------------------------------------------------------
    echo ""
    read -rp "  Comment (optional): " _ufw_ap_comment

    # --- Build and preview rule ----------------------------------------------
    local _ufw_ap_rule
    if [ -n "$_ufw_ap_from" ]; then
        _ufw_ap_rule="ufw allow from $_ufw_ap_from to any port $_ufw_ap_port${_ufw_ap_proto}"
    else
        _ufw_ap_rule="ufw allow $_ufw_ap_port${_ufw_ap_proto}"
    fi
    [ -n "$_ufw_ap_comment" ] && _ufw_ap_rule+=" comment '$_ufw_ap_comment'"

    echo ""
    echo -e "  ${BOLD}Rule Preview:${NC}"
    echo "    $  $_ufw_ap_rule"
    echo ""

    confirm "Apply this rule?" || return 1

    eval "$_ufw_ap_rule" || { error "Failed to add rule."; return 1; }
    info "Rule added successfully."
}

# --- Register ----------------------------------------------------------------
register_action "Allow Port|ufw_allow_port|action_ufw_allow_port"