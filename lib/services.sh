#!/bin/bash
# =============================================================================
# lib/services.sh — Service Registration & Loading
# Sourced by firstboot.sh after globals.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================


# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

# Check if a package is installed
pkg_installed() {
    dpkg -l "$1" 2>/dev/null | grep -q "^ii"
}

# Check if a service is active
svc_running() {
    systemctl is-active --quiet "$1" 2>/dev/null
}

# Get installed version of a package
pkg_version() {
    dpkg -l "$1" 2>/dev/null | awk '/^ii/{print $3}' | head -1
}

# Check if a service is installed based on its SVC_ variable
is_installed() {
    local svcvar="$1"
    [ "${!svcvar}" != "not installed" ]
}

# Check if a service is running based on its SVC_ variable
is_running() {
    local svcvar="$1"
    [ "${!svcvar}" = "running" ]
}




source_services() {
    section "Sourcing Services"
    local _dir
    for _dir in "$SERVICES_DIR"/*/; do
        local _name
        _name="$(basename "$_dir")"
        if [ -f "$_dir/${_name}.sh" ]; then
            source "$_dir/${_name}.sh"
        else
            warn "source_services: no entry script found for service '$_name' — expected $_dir${_name}.sh"
        fi
    done
    unset _dir _name
}

source_service_actions() {
    local _dir="$1"
    for _file in $(ls "$_dir/actions"/*.sh 2>/dev/null | sort); do
        [ -f "$_file" ] && source "$_file"
    done
    unset _file
}

register_service() {
    local entry="$1"
    IFS='|' read -r label svc pkg svcvar groups entry_fn <<< "$entry"

    # Validate all required fields
    if [ -z "$label" ] || [ -z "$svc" ] || [ -z "$pkg" ] || [ -z "$svcvar" ] || [ -z "$groups" ] || [ -z "$entry_fn" ]; then
        warn "register_service: missing required fields in '$entry'"
        warn "  Expected: Label|service|package|SVC_var|groups|entry_fn"
        return 1
    fi

    # Check entry function exists
    if ! declare -f "$entry_fn" > /dev/null 2>&1; then
        warn "register_service: entry function '$entry_fn' not found for service '$label'"
        return 1
    fi

    # Check for duplicate
    for s in "${SERVICES[@]}"; do
        IFS='|' read -r slabel ssvc _ <<< "$s"
        if [ "$ssvc" = "$svc" ]; then
            warn "register_service: service '$label' is already registered — skipping duplicate"
            return 1
        fi
    done

    # Check all groups exist
    IFS=',' read -ra group_list <<< "$groups"
    for group in "${group_list[@]}"; do
        local found=false
        for g in "${SERVICE_GROUPS[@]}"; do
            IFS='|' read -r glabel gname _ <<< "$g"
            [ "$gname" = "$group" ] && found=true && break
        done
        if [ "$found" = false ]; then
            warn "register_service: service '$label' references unknown group '$group' — register group first"
        fi
    done

    SERVICES+=("$entry")
	info "Service [$label] registered"
}

# --- detect_services ---------------------------------------------------------
# Loops over SERVICES array, checks each package/service, updates SVC_* vars
detect_services() {
    local label svc pkg svcvar groups entry_fn

    for entry in "${SERVICES[@]}"; do
        IFS='|' read -r label svc pkg svcvar groups entry_fn <<< "$entry"

        if ! pkg_installed "$pkg"; then
            declare -g "${svcvar}=not installed"
        elif svc_running "$svc"; then
            declare -g "${svcvar}=running"
        else
            declare -g "${svcvar}=stopped"
        fi
    done
}

draw_services_menu() {
    section "Manage a Service"
    local i=1
    for entry in "${SERVICES[@]}"; do
        IFS='|' read -r label svc pkg svcvar groups entry_fn <<< "$entry"
        if pkg_installed "$pkg"; then
            local status="installed"
        else
            local status="not installed"
        fi
        printf "    %d)  %-20s %s\n" "$i" "$label" "$(colorize_status "$status")"
        (( i++ ))
    done
    echo ""
    echo "    0)  Back"
    echo ""
}

services_menu() {
    while true; do
        draw_services_menu
        read -rp "  Selection: " SERVICES_CHOICE

        if [ "$SERVICES_CHOICE" = "0" ]; then
            break
        fi

        # Validate it's a number
        if ! [[ "$SERVICES_CHOICE" =~ ^[0-9]+$ ]]; then
            warn "Invalid selection."
            continue
        fi

        # Get the selected service entry
        local idx=$(( SERVICES_CHOICE - 1 ))
        if [ "$idx" -lt 0 ] || [ "$idx" -ge "${#SERVICES[@]}" ]; then
            warn "Invalid selection."
            continue
        fi

        local entry="${SERVICES[$idx]}"
        IFS='|' read -r label svc pkg svcvar groups entry_fn <<< "$entry"

        # Call the entry function
        if declare -f "$entry_fn" > /dev/null 2>&1; then
            "$entry_fn"
        else
            warn "Entry function '$entry_fn' not found for service '$label'."
        fi
    done
    unset SERVICES_CHOICE
}

export -f pkg_installed svc_running pkg_version is_installed is_running
export -f source_services register_service detect_services