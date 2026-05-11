#!/bin/bash
# =============================================================================
# modules/groups/database.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Entry function ----------------------------------------------------------
setup_database() {
    local -a DATABASE_MENU_OPTIONS=()

    for entry in "${SERVICES[@]}"; do
        IFS='|' read -r label svc pkg svcvar groups entry_fn <<< "$entry"
        if [[ ",$groups," == *",database,"* ]]; then
            DATABASE_MENU_OPTIONS+=("$label|$entry_fn")
        fi
    done

    if [ ${#DATABASE_MENU_OPTIONS[@]} -eq 0 ]; then
        warn "No database services registered."
        return 1
    fi

    command_menu DATABASE_MENU_OPTIONS "Database"
}

# --- Register ----------------------------------------------------------------
register_group "Database|database|setup_database"