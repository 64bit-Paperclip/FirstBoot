	#!/bin/bash
# =============================================================================
# modules/actions/mysql_install.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Action ------------------------------------------------------------------
action_mysql_install() {
    
    if pkg_installed "mysql-server"; then
        warn "MySQL is already installed."
        return 1
    fi

    section "Installing MySQL"

    info "Updating package list..."
    run_system_cmd apt update -qq || { error "Failed to update package list."; return 1; }

    info "Installing MySQL..."
    run_system_cmd apt install -y mysql-server || { error "Failed to install MySQL."; return 1; }

    info "Securing MySQL installation..."
    mysql -u root <<EOF || { error "Failed to secure MySQL."; return 1; }
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
EOF

    systemctl enable mysql
    systemctl start mysql

    if ! systemctl is-active --quiet mysql; then
        warn "MySQL may not have started correctly — check: journalctl -u mysql"
        return 1
    fi

    info "MySQL installed and secured."
}

# --- Register ----------------------------------------------------------------
register_action "Install MySQL|mysql_install|action_mysql_install"