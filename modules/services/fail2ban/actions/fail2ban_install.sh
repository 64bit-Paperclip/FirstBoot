#!/bin/bash
# =============================================================================
# modules/services/fail2ban/actions/fail2ban_install.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Action ------------------------------------------------------------------
action_fail2ban_install() {

    if is_fail2ban_installed; then
        warn "Fail2ban is already installed."
        return 1
    fi

    section "Installing Fail2ban"

    info "Updating package list..."
    apt update -qq || { error "Failed to update package list."; return 1; }

    info "Installing Fail2ban..."
    apt install -y fail2ban || { error "Failed to install Fail2ban."; return 1; }

    section "Fail2ban Configuration"

    # Ban time
    read -rp "  Ban duration [1h]: " _F2B_BANTIME
    _F2B_BANTIME="${_F2B_BANTIME:-1h}"

    # Find time
    read -rp "  Time window to count attempts [10m]: " _F2B_FINDTIME
    _F2B_FINDTIME="${_F2B_FINDTIME:-10m}"

    # Max retries
    read -rp "  Max attempts before ban [5]: " _F2B_MAXRETRY
    _F2B_MAXRETRY="${_F2B_MAXRETRY:-5}"

# Write default settings to jail.local
    info "Writing default configuration..."
    cat > /etc/fail2ban/jail.local <<EOF
[DEFAULT]
bantime  = ${_F2B_BANTIME}
findtime = ${_F2B_FINDTIME}
maxretry = ${_F2B_MAXRETRY}
backend  = systemd
EOF

    # Write sshd jail to jail.d
    info "Configuring SSH jail..."
    mkdir -p /etc/fail2ban/jail.d
    cat > /etc/fail2ban/jail.d/sshd.conf <<EOF
[sshd]
enabled  = true
port     = ssh
logpath  = %(sshd_log)s
maxretry = 3
bantime  = 24h
EOF

    systemctl enable fail2ban
    systemctl start fail2ban

    if ! systemctl is-active --quiet fail2ban; then
        warn "Fail2ban may not have started correctly -- check: journalctl -u fail2ban"
        return 1
    fi

    info "Fail2ban installed and configured."

    _fail2ban_install_cleanup
}

_fail2ban_install_cleanup()
{
    unset _F2B_BANTIME _F2B_FINDTIME _F2B_MAXRETRY
}

# --- Register ----------------------------------------------------------------
register_action "Install Fail2ban|fail2ban_install|action_fail2ban_install"