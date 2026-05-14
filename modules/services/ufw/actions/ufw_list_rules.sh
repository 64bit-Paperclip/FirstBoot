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
        warn "UFW is inactive -- rules exist but are not being enforced."
        echo ""
    fi

    local _ufw_lr_rules
    _ufw_lr_rules=$(ufw_get_rules)

    if [ -z "$_ufw_lr_rules" ]; then
        echo ""
        info "No rules configured."
        echo ""
        return 0
    fi

    echo ""
    printf "    %-40s %s\n" "Rule" "Comment"
    printf "    %-40s %s\n" "----------------------------------------" "-------"

    echo "$_ufw_lr_rules" | while IFS= read -r _ufw_lr_line; do
        local _ufw_lr_rule _ufw_lr_comment
        _ufw_lr_comment=$(echo "$_ufw_lr_line" | grep -oP "comment '\K[^']*" || echo "")
        _ufw_lr_rule=$(echo "$_ufw_lr_line" | sed "s/ comment '.*'//")
        printf "    %-40s %s\n" "$_ufw_lr_rule" "$_ufw_lr_comment"
    done

    echo ""
}

# --- Register ----------------------------------------------------------------
register_action "List UFW Rules|ufw_list_rules|action_ufw_list_rules"