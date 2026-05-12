#!/bin/bash
# =============================================================================
# lib/groups.sh — Service Group Registration & Loading
# Sourced by firstboot.sh after globals.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

source_groups() {
    
    local _dir
    for _dir in "$SERVICE_GROUPS_DIR"/*/; do
        local _name
        _name="$(basename "$_dir")"
        if [ -f "$_dir/${_name}.sh" ]; then
            source "$_dir/${_name}.sh"
        else
            warn "source_groups: no entry script found for group '$_name' — expected $_dir${_name}.sh"
        fi
    done
    
}

register_group() {
    local entry="$1"
    IFS='|' read -r label name entry_fn <<< "$entry"

    # Validate all fields are present
    if [ -z "$label" ] || [ -z "$name" ] || [ -z "$entry_fn" ]; then
        warn "register_group: missing required fields in '$entry'"
        warn "  Expected: Label|name|entry_fn"
        return 1
    fi

    # Check entry function exists
    if ! declare -f "$entry_fn" > /dev/null 2>&1; then
        warn "register_group: entry function '$entry_fn' not found for group '$name'"
        return 1
    fi

    # Check for duplicate
    for g in "${SERVICE_GROUPS[@]}"; do
        IFS='|' read -r glabel gname _ <<< "$g"
        if [ "$gname" = "$name" ]; then
            warn "register_group: group '$name' is already registered — skipping duplicate"
            return 1
        fi
    done

    SERVICE_GROUPS+=("$entry")
	info "Service Group [$label] registered"
}

draw_groups_menu() {
    
    section "Service Groups"
    
    local i=1
    for entry in "${SERVICE_GROUPS[@]}"; do
        IFS='|' read -r label name entry_fn <<< "$entry"
        printf "    %d)  %s\n" "$i" "$label"
        (( i++ ))
    done
    echo ""
    echo "    0)  Back"
    echo ""
}

groups_menu() {
    while true; do
        draw_groups_menu
        read -rp "  Selection: " GROUPS_CHOICE

        if [ "$GROUPS_CHOICE" = "0" ]; then
            break
        fi

        # Validate it's a number
        if ! [[ "$GROUPS_CHOICE" =~ ^[0-9]+$ ]]; then
            warn "Invalid selection."
            continue
        fi

        # Get the selected group entry
        local idx=$(( GROUPS_CHOICE - 1 ))
        if [ "$idx" -lt 0 ] || [ "$idx" -ge "${#SERVICE_GROUPS[@]}" ]; then
            warn "Invalid selection."
            continue
        fi

        local entry="${SERVICE_GROUPS[$idx]}"
        IFS='|' read -r label name entry_fn <<< "$entry"

        # Call the entry function
        if declare -f "$entry_fn" > /dev/null 2>&1; then
            "$entry_fn"
        else
            warn "Entry function '$entry_fn' not found for group '$label'."
        fi
    done
    unset GROUPS_CHOICE
}



export -f source_groups register_service