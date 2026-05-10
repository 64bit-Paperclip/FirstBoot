#!/bin/bash
# =============================================================================
# lib/groups.sh — Service Group Registration & Loading
# Sourced by firstboot.sh after globals.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

source_groups() {
    section "Sourcing Service Groups"
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
    unset _dir _name
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

export -f source_groups register_service