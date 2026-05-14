#!/bin/bash
# =============================================================================
# modules/services/unattended/actions/unattended_install.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Action ------------------------------------------------------------------
action_unattended_install() {

    if is_unattended_upgrades_installed; then
        warn "Unattended Upgrades is already installed."
        return 1
    fi

    section "Installing Unattended Upgrades"

    info "Updating package list..."
    apt update -qq || { error "Failed to update package list."; return 1; }

    info "Installing Unattended Upgrades..."
    apt install -y unattended-upgrades apt-listchanges || { error "Failed to install Unattended Upgrades."; return 1; }

    section "Configuration"

    # --- Update types --------------------------------------------------------
    echo ""
    echo "  Which updates should be applied automatically?"
    echo ""
    echo "    1)  Security updates only  (recommended)"
    echo "    2)  All updates"
    echo ""

    local _uau_update_type
    while true; do
        read -rp "  Selection [1]: " _uau_update_type
        _uau_update_type="${_uau_update_type:-1}"
        case "$_uau_update_type" in
            1|2) break ;;
            *) warn "Invalid selection -- enter 1 or 2." ;;
        esac
    done

    # --- Auto reboot ---------------------------------------------------------
    echo ""
    local _uau_autoreboot=false
    local _uau_reboot_time="02:00"
    if confirm_prompt "Automatically reboot if required?"; then
        _uau_autoreboot=true
        read -rp "  Reboot time [02:00]: " _uau_reboot_time
        _uau_reboot_time="${_uau_reboot_time:-02:00}"
    fi

    # --- Remove unused deps --------------------------------------------------
    echo ""
    local _uau_autoremove=false
    confirm_prompt "Automatically remove unused dependencies?" && _uau_autoremove=true

    # --- Write configuration -------------------------------------------------
    info "Writing configuration..."

    local _uau_all_updates=""
    [ "$_uau_update_type" = "2" ] && _uau_all_updates='
Unattended-Upgrade::Origins-Pattern {
    "origin=*";
};'

    cat > /etc/apt/apt.conf.d/50unattended-upgrades <<EOF
Unattended-Upgrade::Allowed-Origins {
    "\${distro_id}:\${distro_codename}";
    "\${distro_id}:\${distro_codename}-security";
    "\${distro_id}ESMApps:\${distro_codename}-apps-security";
    "\${distro_id}ESM:\${distro_codename}-infra-security";
};
${_uau_all_updates}
Unattended-Upgrade::Package-Blacklist {};
Unattended-Upgrade::AutoFixInterruptedDpkg "true";
Unattended-Upgrade::MinimalSteps "true";
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
Unattended-Upgrade::Remove-New-Unused-Dependencies "$( [ "$_uau_autoremove" = true ] && echo "true" || echo "false" )";
Unattended-Upgrade::Remove-Unused-Dependencies "$( [ "$_uau_autoremove" = true ] && echo "true" || echo "false" )";
Unattended-Upgrade::Automatic-Reboot "$( [ "$_uau_autoreboot" = true ] && echo "true" || echo "false" )";
Unattended-Upgrade::Automatic-Reboot-Time "${_uau_reboot_time}";
EOF

    cat > /etc/apt/apt.conf.d/20auto-upgrades <<EOF
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";
EOF

    systemctl enable unattended-upgrades
    systemctl start unattended-upgrades

    if ! is_unattended_running; then
        warn "Unattended Upgrades may not have started correctly -- check: journalctl -u unattended-upgrades"
        return 1
    fi

    info "Unattended Upgrades installed and configured."
}

# --- Register ----------------------------------------------------------------
register_action "Install Unattended Upgrades|unattended_install|action_unattended_install"