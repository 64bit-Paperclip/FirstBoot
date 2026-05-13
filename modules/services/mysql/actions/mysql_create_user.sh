#!/bin/bash
# =============================================================================
# modules/services/mysql/actions/mysql_create_user.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Action ------------------------------------------------------------------
action_mysql_create_user() {
    section "Create MySQL User"

    if ! pkg_installed "$MYSQL_PACKAGE"; then
        warn "MySQL is not installed."
        return 1
    fi

    if ! svc_running "$MYSQL_SERVICE"; then
        warn "MySQL is not running."
        return 1
    fi

    # --- Username ------------------------------------------------------------
    local _mysql_cu_user
    while true; do
        read -rp "  Username: " _mysql_cu_user
        if [ -z "$_mysql_cu_user" ]; then
            warn "Username cannot be empty."
        elif [[ ! "$_mysql_cu_user" =~ ^[a-zA-Z0-9_]+$ ]]; then
            warn "Username can only contain letters, numbers, and underscores."
        elif [ "$(mysql -u root -se "SELECT COUNT(*) FROM mysql.user WHERE User='${_mysql_cu_user}';" 2>/dev/null)" -gt 0 ]; then
            warn "User '$_mysql_cu_user' already exists."
        else
            break
        fi
    done

    # --- Host ----------------------------------------------------------------
    echo ""
    echo "  Where can this user connect from?"
    echo "    1)  localhost only"
    echo "    2)  Current IP ($CURRENT_IP)"
    echo "    3)  Anywhere (%)"
    echo "    4)  Custom IP"
    echo ""

    local _mysql_cu_host
    while true; do
        read -rp "  Selection: " _mysql_cu_host_choice
        case "$_mysql_cu_host_choice" in
            1) _mysql_cu_host="localhost" ; break ;;
            2) _mysql_cu_host="$CURRENT_IP" ; break ;;
            3) _mysql_cu_host="%" ; break ;;
            4)
                while true; do
                    read -rp "  Custom IP: " _mysql_cu_host
                    if [[ "$_mysql_cu_host" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
                        break
                    fi
                    warn "Invalid IP address."
                done
                break
                ;;
            *) warn "Invalid selection — enter 1, 2, 3, or 4." ;;
        esac
    done

    # --- Password ------------------------------------------------------------
    echo ""
    local _mysql_cu_pass _mysql_cu_pass_confirm
    while true; do
        read -rsp "  Password: " _mysql_cu_pass
        echo ""
        if [ -z "$_mysql_cu_pass" ]; then
            warn "Password cannot be empty."
            continue
        fi
        read -rsp "  Confirm password: " _mysql_cu_pass_confirm
        echo ""
        if [ "$_mysql_cu_pass" != "$_mysql_cu_pass_confirm" ]; then
            warn "Passwords do not match."
        else
            break
        fi
    done

    # --- Create user ---------------------------------------------------------
    mysql -u root <<EOF || { error "Failed to create user."; return 1; }
CREATE USER '${_mysql_cu_user}'@'${_mysql_cu_host}' IDENTIFIED BY '${_mysql_cu_pass}';
FLUSH PRIVILEGES;
EOF

    info "User '${_mysql_cu_user}'@'${_mysql_cu_host}' created."

    # --- Grant privileges ----------------------------------------------------
    echo ""
    if confirm_prompt "Set up privileges for this user now?"; then
        if declare -f action_mysql_grant_privileges > /dev/null 2>&1; then
            MYSQL_GRANT_USER="$_mysql_cu_user"
            MYSQL_GRANT_HOST="$_mysql_cu_host"
            action_mysql_grant_privileges
            unset MYSQL_GRANT_USER MYSQL_GRANT_HOST
        else
            warn "Grant privileges action not found."
        fi
    fi
}

# --- Register ----------------------------------------------------------------
register_action "Create MySQL User|mysql_create_user|action_mysql_create_user"