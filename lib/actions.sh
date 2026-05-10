#!/bin/bash
# =============================================================================
# lib/actions.sh — Action Registration & Loading
# Sourced by firstboot.sh after globals.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

source_actions() {
    section "Sourcing Actions"
    local _file
    for _file in "$ACTIONS_DIR"/*.sh; do
        [ -f "$_file" ] && source "$_file"
    done
    unset _file
}

register_action() {
    local entry="$1"
    IFS='|' read -r label name entry_fn <<< "$entry"

    # Validate all fields are present
    if [ -z "$label" ] || [ -z "$name" ] || [ -z "$entry_fn" ]; then
        warn "register_action: missing required fields in '$entry'"
        warn "  Expected: Label|name|entry_fn"
        return 1
    fi

    # Check entry function exists
    if ! declare -f "$entry_fn" > /dev/null 2>&1; then
        warn "register_action: entry function '$entry_fn' not found for action '$name'"
        return 1
    fi

    # Check for duplicate
    for a in "${ACTIONS[@]}"; do
        IFS='|' read -r alabel aname _ <<< "$a"
        if [ "$aname" = "$name" ]; then
            warn "register_action: action '$name' is already registered — skipping duplicate"
            return 1
        fi
    done

    ACTIONS+=("$entry")
    info "Action [$label] registered"
}

draw_actions_menu() {
    
    section "Run an Action"
    
    local i=1
    for entry in "${ACTIONS[@]}"; do
        IFS='|' read -r label name entry_fn <<< "$entry"
        printf "    %d)  %s\n" "$i" "$label"
        (( i++ ))
    done
    echo ""
    echo "    0)  Back"
    echo ""
}