#!/bin/bash
# =============================================================================
# modules/services/ufw/actions/ufw_delete_rule.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Action ------------------------------------------------------------------
action_ufw_delete_rule() {
    section "Delete UFW Rule"

    if ! is_ufw_installed; then
        warn "UFW is not installed."
        return 1
    fi

    # --- Show current rules --------------------------------------------------
    local _ufw_dr_rules
    _ufw_dr_rules=$(ufw status numbered 2>/dev/null | grep -E "^\[")

    if [ -z "$_ufw_dr_rules" ]; then
        info "No rules configured."
        return 0
    fi

    echo ""
    echo "$_ufw_dr_rules" | while IFS= read -r _ufw_dr_line; do
        local _ufw_dr_num _ufw_dr_to _ufw_dr_action _ufw_dr_from
        _ufw_dr_num=$(echo "$_ufw_dr_line" | awk -F'[][]' '{print $2}')
        _ufw_dr_to=$(echo "$_ufw_dr_line" | awk '{print $2}')
        _ufw_dr_action=$(echo "$_ufw_dr_line" | awk '{print $3}')
        _ufw_dr_from=$(echo "$_ufw_dr_line" | awk '{print $4}')
        printf "    [%s]  %-30s %-15s %s\n" "$_ufw_dr_num" "$_ufw_dr_to" "$_ufw_dr_action" "$_ufw_dr_from"
    done
    echo ""

    # --- Select rule to delete -----------------------------------------------
    local _ufw_dr_max
    _ufw_dr_max=$(echo "$_ufw_dr_rules" | wc -l)

    local _ufw_dr_choice
    while true; do
        read -rp "  Enter rule number to delete: " _ufw_dr_choice
        if [[ "$_ufw_dr_choice" =~ ^[0-9]+$ ]] && \
           [ "$_ufw_dr_choice" -ge 1 ] && \
           [ "$_ufw_dr_choice" -le "$_ufw_dr_max" ]; then
            break
        fi
        warn "Invalid rule number."
    done

    # --- Show rule and confirm ------------------------------------------------
    local _ufw_dr_selected
    _ufw_dr_selected=$(echo "$_ufw_dr_rules" | grep "^\[${_ufw_dr_choice}\]")

    echo ""
    warn "This will delete the following rule:"
    echo "    $_ufw_dr_selected"
    echo ""

    confirm "Are you sure?" || return 1

    echo "y" | ufw delete "$_ufw_dr_choice" 2>/dev/null || { error "Failed to delete rule."; return 1; }
    info "Rule deleted successfully."
}

# --- Register ----------------------------------------------------------------
register_action "Delete UFW Rule|ufw_delete_rule|action_ufw_delete_rule"