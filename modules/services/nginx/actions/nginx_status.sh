#!/bin/bash
# =============================================================================
# modules/services/nginx/actions/nginx_status.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Action ------------------------------------------------------------------
action_nginx_status() {
    section "Nginx Status"

    # Installation
    if ! pkg_installed "nginx"; then
        echo -e "  ${BOLD}Nginx Not Installed:${NC}"
        return 0
    fi

    echo -e "  ${BOLD}Version:${NC}      $(nginx -v 2>&1 | awk -F'/' '{print $2}')"

    # Running state
    if systemctl is-active --quiet nginx; then
        echo -e "  ${BOLD}Status:${NC}      $(colorize_status "running")"
    else
        echo -e "  ${BOLD}Status:${NC}      $(colorize_status "stopped")"
    fi

    # Boot enabled
    if systemctl is-enabled --quiet nginx; then
        echo -e "  ${BOLD}Boot start:${NC}   ${GREEN}enabled${NC}"
    else
        echo -e "  ${BOLD}Boot start:${NC}   ${YELLOW}disabled${NC}"
    fi

    # Config test
    echo ""
    echo -e "  ${BOLD}Config check:${NC}"
    if nginx -t 2>/dev/null; then
        echo -e "    ${GREEN}Configuration OK${NC}"
    else
        echo -e "    ${RED}Configuration has errors:${NC}"
        nginx -t 2>&1 | sed 's/^/    /'
    fi

    # Sites available vs enabled
    echo ""
    echo -e "  ${BOLD}Sites:${NC}"
    echo ""

    local available=()
    local enabled=()

    for site in /etc/nginx/sites-available/*; do
        [ -f "$site" ] && available+=("$(basename "$site")")
    done

    for site in /etc/nginx/sites-enabled/*; do
        [ -L "$site" ] && enabled+=("$(basename "$site")")
    done

    if [ ${#available[@]} -eq 0 ]; then
        echo "    No sites configured."
    else
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
    fi

    section_end "Nginx Status"
}

# --- Register ----------------------------------------------------------------
register_action "Nginx Status|nginx_status|action_nginx_status"