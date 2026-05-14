#!/bin/bash
# =============================================================================
# modules/services/unattended/actions/unattended_status.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Action ------------------------------------------------------------------
action_unattended_upgrades_status() {
    section "Unattended Upgrades Status"

    # --- Installation --------------------------------------------------------
    if ! is_unattended_upgrades_installed; then
        echo -e "  ${BOLD}State:${NC}          $(colorize_status "not installed")"
        return 0
    fi

    echo -e "  ${BOLD}State:${NC}          $(colorize_status "running")"
    echo -e "  ${BOLD}Version:${NC}        $(pkg_version "$UNATTENDED_PACKAGE")"

    # --- Timers --------------------------------------------------------------
    echo ""
    echo -e "  ${BOLD}Timers:${NC}"
    echo ""

    local _uau_st_daily _uau_st_upgrade
    systemctl is-active --quiet apt-daily.timer 2>/dev/null \
        && _uau_st_daily="${GREEN}active${NC}" \
        || _uau_st_daily="${RED}inactive${NC}"
    systemctl is-active --quiet apt-daily-upgrade.timer 2>/dev/null \
        && _uau_st_upgrade="${GREEN}active${NC}" \
        || _uau_st_upgrade="${RED}inactive${NC}"

    printf "    %-35s " "apt-daily.timer (download):"
    echo -e "$_uau_st_daily"
    printf "    %-35s " "apt-daily-upgrade.timer (install):"
    echo -e "$_uau_st_upgrade"

    # --- Next run ------------------------------------------------------------
    echo ""
    echo -e "  ${BOLD}Schedule:${NC}"
    echo ""

    local _uau_st_next_daily _uau_st_next_upgrade
    _uau_st_next_daily=$(systemctl status apt-daily.timer 2>/dev/null | grep "Trigger:" | awk '{print $2, $3}')
    _uau_st_next_upgrade=$(systemctl status apt-daily-upgrade.timer 2>/dev/null | grep "Trigger:" | awk '{print $2, $3}')

    echo "    Next download:  ${_uau_st_next_daily:-unknown}"
    echo "    Next install:   ${_uau_st_next_upgrade:-unknown}"

    # --- Last run ------------------------------------------------------------
    echo ""
    echo -e "  ${BOLD}Last Run:${NC}"
    echo ""

    local _uau_st_last
    _uau_st_last=$(grep "Unattended upgrade returned" /var/log/unattended-upgrades/unattended-upgrades.log 2>/dev/null | tail -1)
    if [ -z "$_uau_st_last" ]; then
        echo "    No recent runs found."
    else
        echo "    $_uau_st_last"
    fi

    # --- Configuration -------------------------------------------------------
    echo ""
    echo -e "  ${BOLD}Configuration:${NC}"
    echo ""

    local _uau_st_conf="/etc/apt/apt.conf.d/50unattended-upgrades"
    if [ ! -f "$_uau_st_conf" ]; then
        warn "Configuration file not found: $_uau_st_conf"
    else
        local _uau_st_autoreboot _uau_st_reboot_time _uau_st_autoremove
        _uau_st_autoreboot=$(grep "^Unattended-Upgrade::Automatic-Reboot " "$_uau_st_conf" 2>/dev/null | grep -oP '"[^"]*"' | tr -d '"')
        _uau_st_reboot_time=$(grep "^Unattended-Upgrade::Automatic-Reboot-Time" "$_uau_st_conf" 2>/dev/null | grep -oP '"[^"]*"' | tr -d '"')
        _uau_st_autoremove=$(grep "^Unattended-Upgrade::Remove-Unused-Dependencies" "$_uau_st_conf" 2>/dev/null | grep -oP '"[^"]*"' | tr -d '"')

        echo "    Auto reboot:    ${_uau_st_autoreboot:-unknown}"
        echo "    Reboot time:    ${_uau_st_reboot_time:-unknown}"
        echo "    Auto remove:    ${_uau_st_autoremove:-unknown}"
    fi

    echo ""
}

# --- Register ----------------------------------------------------------------
register_action "Unattended Upgrades Status|unattended_upgrades_status|action_unattended_upgrades_status"