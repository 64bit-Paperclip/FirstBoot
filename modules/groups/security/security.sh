#!/bin/bash
# =============================================================================
# modules/groups/security.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Entry function ----------------------------------------------------------
setup_security() {
    local -a SECURITY_MENU_OPTIONS=()

    for entry in "${SERVICES[@]}"; do
        IFS='|' read -r label svc pkg svcvar groups entry_fn <<< "$entry"
        if [[ ",$groups," == *",security,"* ]]; then
            SECURITY_MENU_OPTIONS+=("$label|$entry_fn")
        fi
    done

    if [ ${#SECURITY_MENU_OPTIONS[@]} -eq 0 ]; then
        warn "No security services registered."
        return 1
    fi

    command_menu SECURITY_MENU_OPTIONS "Security"
}

# --- Register ----------------------------------------------------------------
register_group "Security|security|setup_security"