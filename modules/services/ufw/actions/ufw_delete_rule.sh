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

    # --- Get rules -----------------------------------------------------------
    local _ufw_dr_raw
    _ufw_dr_raw=$(ufw_get_rules)

    if [ -z "$_ufw_dr_raw" ]; then
        info "No rules configured."
        return 0
    fi

    # --- Build numbered array of rules ---------------------------------------
    local -a _ufw_dr_rules=()
    while IFS= read -r _ufw_dr_line; do
        [ -n "$_ufw_dr_line" ] && _ufw_dr_rules+=("$_ufw_dr_line")
    done <<< "$_ufw_dr_raw"

    # --- Display rules -------------------------------------------------------
    echo ""
    local _ufw_dr_idx=1
    for _ufw_dr_rule in "${_ufw_dr_rules[@]}"; do
        local _ufw_dr_display _ufw_dr_comment
        _ufw_dr_comment=$(echo "$_ufw_dr_rule" | grep -oP "comment '\K[^']*" || echo "")
        _ufw_dr_display=$(echo "$_ufw_dr_rule" | sed "s/ comment '.*'//")
        if [ -n "$_ufw_dr_comment" ]; then
            printf "    %d)  %-40s # %s\n" "$_ufw_dr_idx" "$_ufw_dr_display" "$_ufw_dr_comment"
        else
            printf "    %d)  %s\n" "$_ufw_dr_idx" "$_ufw_dr_display"
        fi
        (( _ufw_dr_idx++ ))
    done
    echo ""

    # --- Select rule ---------------------------------------------------------
    local _ufw_dr_choice
    while true; do
        read -rp "  Enter rule number to delete: " _ufw_dr_choice
        if [[ "$_ufw_dr_choice" =~ ^[0-9]+$ ]] && \
           [ "$_ufw_dr_choice" -ge 1 ] && \
           [ "$_ufw_dr_choice" -le "${#_ufw_dr_rules[@]}" ]; then
            break
        fi
        warn "Invalid rule number."
    done

    local _ufw_dr_selected="${_ufw_dr_rules[$(( _ufw_dr_choice - 1 ))]}"

    # --- Confirm and delete --------------------------------------------------
    echo ""
    warn "This will delete the following rule:"
    echo "    $_ufw_dr_selected"
    echo ""

    confirm "Are you sure?" || return 1

    # Strip 'ufw ' prefix if present and build delete command
    local _ufw_dr_cmd
    _ufw_dr_cmd=$(echo "$_ufw_dr_selected" | sed 's/^ufw //')
    ufw delete $ufw_dr_cmd 2>/dev/null || { error "Failed to delete rule."; return 1; }
    info "Rule deleted successfully."
}

# --- Register ----------------------------------------------------------------
register_action "Delete UFW Rule|ufw_delete_rule|action_ufw_delete_rule"