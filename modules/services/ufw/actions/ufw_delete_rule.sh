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

    # --- Requires UFW to be active -------------------------------------------
    if ! is_ufw_running; then
        warn "UFW must be active to delete rules by number."
        confirm "Enable UFW now?" || return 1
        echo "y" | ufw enable 2>/dev/null || { error "Failed to enable UFW."; return 1; }
        info "UFW enabled."
    fi

    # --- Get numbered rules --------------------------------------------------
    local _ufw_dr_raw
    _ufw_dr_raw=$(ufw status numbered 2>/dev/null | grep -E "^\[ *[0-9]+\]")

    if [ -z "$_ufw_dr_raw" ]; then
        info "No rules configured."
        return 0
    fi

    # --- Display rules -------------------------------------------------------
    echo ""
    echo "$_ufw_dr_raw" | sed 's/^/    /'
    echo ""

    # --- Select rule ---------------------------------------------------------
    local _ufw_dr_max
    _ufw_dr_max=$(echo "$_ufw_dr_raw" | wc -l)

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

    # --- Show selected rule and confirm --------------------------------------
    local _ufw_dr_selected
    _ufw_dr_selected=$(echo "$_ufw_dr_raw" | grep -E "^\[ *${_ufw_dr_choice}\]")

    echo ""
    warn "This will delete the following rule:"
    echo "    $_ufw_dr_selected"
    echo ""

    confirm_prompt "Are you sure?" || return 1

    echo "y" | ufw delete "$_ufw_dr_choice" 2>/dev/null || { error "Failed to delete rule."; return 1; }
    info "Rule deleted successfully."
}

# --- Register ----------------------------------------------------------------
register_action "Delete UFW Rule|ufw_delete_rule|action_ufw_delete_rule"