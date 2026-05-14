#!/bin/bash
# =============================================================================
# modules/services/ufw/actions/ufw_list_rules.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Action ------------------------------------------------------------------
action_ufw_list_rules() {
    section "UFW Rules"

    if ! is_ufw_installed; then
        warn "UFW is not installed."
        return 1
    fi

    if ! ufw status 2>/dev/null | grep -q "Status: active"; then
        warn "UFW is inactive -- no rules are being enforced."
        echo ""
    fi

    local _ufw_lr_rules
    _ufw_lr_rules=$(ufw status numbered 2>/dev/null | grep -E "^\[")

    if [ -z "$_ufw_lr_rules" ]; then
        echo ""
        info "No rules configured."
        echo ""
        return 0
    fi

    echo ""
    printf "    %-6s %-30s %-15s %-20s %s\n" "Num" "To" "Action" "From" "Comment"
    printf "    %-6s %-30s %-15s %-20s %s\n" "------" "------------------------------" "---------------" "--------------------" "-------"

    echo "$_ufw_lr_rules" | while IFS= read -r _ufw_lr_line; do
        local _ufw_lr_num _ufw_lr_to _ufw_lr_action _ufw_lr_from _ufw_lr_comment
        _ufw_lr_num=$(echo "$_ufw_lr_line" | awk -F'[][]' '{print $2}')
        _ufw_lr_to=$(echo "$_ufw_lr_line" | awk '{print $2}')
        _ufw_lr_action=$(echo "$_ufw_lr_line" | awk '{print $3}')
        _ufw_lr_from=$(echo "$_ufw_lr_line" | awk '{print $4}')
        _ufw_lr_comment=$(echo "$_ufw_lr_line" | grep -oP '\#\s*\K.*' || echo "")
        printf "    %-6s %-30s %-15s %-20s %s\n" "$_ufw_lr_num" "$_ufw_lr_to" "$_ufw_lr_action" "$_ufw_lr_from" "$_ufw_lr_comment"
    done

    echo ""
}

# --- Register ----------------------------------------------------------------
register_action "List UFW Rules|ufw_list_rules|action_ufw_list_rules"