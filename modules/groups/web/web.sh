#!/bin/bash
# =============================================================================
# modules/web.sh
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# TODO: not yet implemented
# =============================================================================
 

# --- Entry function ----------------------------------------------------------
setup_web() {
    local -a WEB_MENU_OPTIONS=()

    for entry in "${SERVICES[@]}"; do
        IFS='|' read -r label svc pkg svcvar groups entry_fn <<< "$entry"
        if [[ ",$groups," == *",web,"* ]]; then
            WEB_MENU_OPTIONS+=("$label|$entry_fn")
        fi
    done

    if [ ${#WEB_MENU_OPTIONS[@]} -eq 0 ]; then
        warn "No web services registered."
        return 1
    fi

    command_menu WEB_MENU_OPTIONS "Web"
}

# --- Register ----------------------------------------------------------------
register_group "Web|web|setup_web"