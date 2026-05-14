#!/bin/bash
# =============================================================================
# modules/services/ufw/actions/ufw_deny_port.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Action ------------------------------------------------------------------
action_ufw_deny_port() {
    section "Deny Port"

    if ! is_ufw_installed; then
        warn "UFW is not installed."
        return 1
    fi

    # --- Port ----------------------------------------------------------------
    local _ufw_dp_port
    while true; do
        read -rp "  Port or service (e.g. 80, 443, ssh, http): " _ufw_dp_port
        if [ -z "$_ufw_dp_port" ]; then
            warn "Port cannot be empty."
        elif [[ ! "$_ufw_dp_port" =~ ^[0-9a-zA-Z]+$ ]]; then
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

    local _ufw_dp_proto=""
    while true; do
        read -rp "  Selection [1]: " _ufw_dp_proto_choice
        _ufw_dp_proto_choice="${_ufw_dp_proto_choice:-1}"
        case "$_ufw_dp_proto_choice" in
            1) _ufw_dp_proto=""    ; break ;;
            2) _ufw_dp_proto="/tcp"; break ;;
            3) _ufw_dp_proto="/udp"; break ;;
            *) warn "Invalid selection -- enter 1, 2, or 3." ;;
        esac
    done

    # --- Source IP -----------------------------------------------------------
    echo ""
    echo "  Deny from:"
    echo "    1)  Anywhere"
    echo "    2)  Current IP ($CURRENT_IP)"
    echo "    3)  Specific IP"
    echo "    4)  Specific subnet"
    echo ""

    local _ufw_dp_from=""
    while true; do
        read -rp "  Selection [1]: " _ufw_dp_from_choice
        _ufw_dp_from_choice="${_ufw_dp_from_choice:-1}"
        case "$_ufw_dp_from_choice" in
            1) _ufw_dp_from=""             ; break ;;
            2) _ufw_dp_from="$CURRENT_IP"  ; break ;;
            3)
                while true; do
                    read -rp "  IP address: " _ufw_dp_from
                    if [[ "$_ufw_dp_from" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
                        break
                    fi
                    warn "Invalid IP address."
                done
                break
                ;;
            4)
                while true; do
                    read -rp "  Subnet (e.g. 192.168.1.0/24): " _ufw_dp_from
                    if [[ "$_ufw_dp_from" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}$ ]]; then
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
    read -rp "  Comment (optional): " _ufw_dp_comment

    # --- Build and preview rule ----------------------------------------------
    local _ufw_dp_rule
    if [ -n "$_ufw_dp_from" ]; then
        _ufw_dp_rule="ufw deny from $_ufw_dp_from to any port $_ufw_dp_port${_ufw_dp_proto}"
    else
        _ufw_dp_rule="ufw deny $_ufw_dp_port${_ufw_dp_proto}"
    fi
    [ -n "$_ufw_dp_comment" ] && _ufw_dp_rule+=" comment '$_ufw_dp_comment'"

    echo ""
    echo -e "  ${BOLD}Rule Preview:${NC}"
    echo "    $  $_ufw_dp_rule"
    echo ""

    confirm "Apply this rule?" || return 1

    eval "$_ufw_dp_rule" || { error "Failed to add rule."; return 1; }
    info "Rule added successfully."
}

# --- Register ----------------------------------------------------------------
register_action "Deny Port|ufw_deny_port|action_ufw_deny_port"