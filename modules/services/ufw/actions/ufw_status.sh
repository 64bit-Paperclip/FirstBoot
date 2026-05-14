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

    # --- Default policies (read from /etc/default/ufw -- works when inactive) -
    echo ""
    echo -e "  ${BOLD}Default Policies:${NC}"
    echo ""

    local _ufw_st_incoming _ufw_st_outgoing _ufw_st_routed _ufw_st_logging
    _ufw_st_incoming=$(grep "^DEFAULT_INPUT_POLICY" /etc/default/ufw 2>/dev/null | cut -d'"' -f2)
    _ufw_st_outgoing=$(grep "^DEFAULT_OUTPUT_POLICY" /etc/default/ufw 2>/dev/null | cut -d'"' -f2)
    _ufw_st_routed=$(grep "^DEFAULT_FORWARD_POLICY" /etc/default/ufw 2>/dev/null | cut -d'"' -f2)
    _ufw_st_logging=$(grep "^LOGLEVEL" /etc/default/ufw 2>/dev/null | cut -d'"' -f2)

    echo "    Incoming:   ${_ufw_st_incoming:-unknown}"
    echo "    Outgoing:   ${_ufw_st_outgoing:-unknown}"
    echo "    Routed:     ${_ufw_st_routed:-unknown}"

    # --- Logging -------------------------------------------------------------
    echo ""
    echo -e "  ${BOLD}Logging:${NC}"
    echo ""
    echo "    Level:      ${_ufw_st_logging:-unknown}"

    # --- Rules ---------------------------------------------------------------
    echo ""
    echo -e "  ${BOLD}Configured Rules:${NC}"
    echo ""

    local _ufw_st_rules
    _ufw_st_rules=$(ufw_get_rules)

    if [ -z "$_ufw_st_rules" ]; then
        echo "    No rules configured."
    else
        printf "    %-40s %s\n" "Rule" "Comment"
        printf "    %-40s %s\n" "----------------------------------------" "-------"
        echo "$_ufw_st_rules" | while IFS= read -r _ufw_st_line; do
            local _ufw_st_rule _ufw_st_comment
            _ufw_st_comment=$(echo "$_ufw_st_line" | grep -oP "comment '\K[^']*" || echo "")
            _ufw_st_rule=$(echo "$_ufw_st_line" | sed "s/ comment '.*'//")
            printf "    %-40s %s\n" "$_ufw_st_rule" "$_ufw_st_comment"
        done
    fi

    if [ "$_ufw_st_active" = false ]; then
        echo ""
        warn "UFW is inactive -- rules are not being enforced."
    fi

    echo ""
}

# --- Register ----------------------------------------------------------------
register_action "UFW Status|ufw_status|action_ufw_status"