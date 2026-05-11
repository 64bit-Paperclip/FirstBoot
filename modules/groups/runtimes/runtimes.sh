#!/bin/bash
# =============================================================================
# modules/groups/runtimes.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Entry function ----------------------------------------------------------
setup_runtimes() {
    local -a RUNTIMES_MENU_OPTIONS=()

    for entry in "${SERVICES[@]}"; do
        IFS='|' read -r label svc pkg svcvar groups entry_fn <<< "$entry"
        if [[ ",$groups," == *",database,"* ]]; then
            RUNTIMES_MENU_OPTIONS+=("$label|$entry_fn")
        fi
    done

    if [ ${#RUNTIMES_MENU_OPTIONS[@]} -eq 0 ]; then
        warn "No runtimes registered."
        return 1
    fi

    command_menu RUNTIMES_MENU_OPTIONS "Runtimes"
}

# --- Register ----------------------------------------------------------------
register_group "Runtimes|runtimes|setup_runtimes"