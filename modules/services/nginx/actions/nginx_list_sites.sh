#!/bin/bash
# =============================================================================
# modules/services/nginx/actions/nginx_list_sites.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Action ------------------------------------------------------------------
action_nginx_list_sites() {
    section "Nginx Sites"

    if ! pkg_installed "nginx"; then
        warn "Nginx is not installed."
        return 1
    fi

    local available=()
    local enabled=()

    for site in /etc/nginx/sites-available/*; do
        [ -f "$site" ] && available+=("$(basename "$site")")
    done

    for site in /etc/nginx/sites-enabled/*; do
        [ -L "$site" ] && enabled+=("$(basename "$site")")
    done

    if [ ${#available[@]} -eq 0 ]; then
        info "No sites configured."
        return 0
    fi

    echo ""
    printf "    %-30s %s\n" "Site" "Status"
    printf "    %-30s %s\n" "──────────────────────────────" "───────────"
    for site in "${available[@]}"; do
        local status="${RED}disabled${NC}"
        for en in "${enabled[@]}"; do
            [ "$en" = "$site" ] && status="${GREEN}enabled${NC}" && break
        done
        printf "    %-30s " "$site"
        echo -e "$status"
    done
    echo ""
}

# --- Register ----------------------------------------------------------------
register_action "List Nginx Sites|nginx_list_sites|action_nginx_list_sites"