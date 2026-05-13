#!/bin/bash
# =============================================================================
# modules/services/ufw/actions/ufw_status.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Action ------------------------------------------------------------------
action_ufw_status() {
    section "UFW Status"

    # --- State ---------------------------------------------------------------
    if ! is_ufw_installed; then
        echo -e "  ${BOLD}State:${NC}          $(colorize_status "not installed")"
        return 0
    fi

    local _ufw_st_active=false
    ufw status 2>/dev/null | grep -q "Status: active" && _ufw_st_active=true

    if [ "$_ufw_st_active" = true ]; then
        echo -e "  ${BOLD}State:${NC}          $(colorize_status "running")"
    else
        echo -e "  ${BOLD}State:${NC}          $(colorize_status "stopped")"
    fi

    # --- Defaults ------------------------------------------------------------
    echo ""
    echo -e "  ${BOLD}Default Policies:${NC}"
    echo ""

    local _ufw_st_incoming _ufw_st_outgoing _ufw_st_routed
    _ufw_st_incoming=$(ufw status verbose 2>/dev/null | grep "^Default:" | awk '{print $2}')
    _ufw_st_outgoing=$(ufw status verbose 2>/dev/null | grep "^Default:" | awk '{print $4}')
    _ufw_st_routed=$(ufw status verbose 2>/dev/null | grep "^Default:" | awk '{print $6}')

    echo "    Incoming:   ${_ufw_st_incoming:-unknown}"
    echo "    Outgoing:   ${_ufw_st_outgoing:-unknown}"
    echo "    Routed:     ${_ufw_st_routed:-unknown}"

    # --- Logging -------------------------------------------------------------
    echo ""
    echo -e "  ${BOLD}Logging:${NC}"
    echo ""

    local _ufw_st_logging
    _ufw_st_logging=$(ufw status verbose 2>/dev/null | grep "^Logging:" | awk '{print $2}')
    echo "    ${_ufw_st_logging:-unknown}"

    if [ "$_ufw_st_active" = false ]; then
        echo ""
        warn "UFW is inactive -- rules are not being enforced."
        return 0
    fi

    # --- Rules ---------------------------------------------------------------
    echo ""
    echo -e "  ${BOLD}Active Rules:${NC}"
    echo ""

    local _ufw_st_rules
    _ufw_st_rules=$(ufw status numbered 2>/dev/null | grep -E "^\[")

    if [ -z "$_ufw_st_rules" ]; then
        echo "    No rules configured."
    else
        printf "    %-6s %-30s %-15s %s\n" "Num" "To" "Action" "From"
        printf "    %-6s %-30s %-15s %s\n" "------" "------------------------------" "---------------" "----"
        echo "$_ufw_st_rules" | while IFS= read -r _ufw_st_line; do
            local _ufw_st_num _ufw_st_to _ufw_st_action _ufw_st_from
            _ufw_st_num=$(echo "$_ufw_st_line" | awk -F'[][]' '{print $2}')
            _ufw_st_to=$(echo "$_ufw_st_line" | awk '{print $2}')
            _ufw_st_action=$(echo "$_ufw_st_line" | awk '{print $3}')
            _ufw_st_from=$(echo "$_ufw_st_line" | awk '{print $4}')
            printf "    %-6s %-30s %-15s %s\n" "$_ufw_st_num" "$_ufw_st_to" "$_ufw_st_action" "$_ufw_st_from"
        done
    fi

    echo ""
}

# --- Register ----------------------------------------------------------------
register_action "UFW Status|ufw_status|action_ufw_status"