#!/bin/bash
# =============================================================================
# modules/services/mysql/utilities/mysql_utilities.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================


# --- Get all non-system user@host pairs --------------------------------------
# Outputs tab-separated User, Host pairs to stdout.
# Excludes system users (root, mysql.sys, etc.)
#
# Returns:
#   0  -- Success
#   1  -- MySQL not accessible
mysql_get_users() {
    mysql -u root -se "SELECT User, Host FROM mysql.user WHERE User NOT IN ('mysql.sys','mysql.session','mysql.infoschema','root') ORDER BY User, Host;" 2>/dev/null
}
 
# --- Drop a specific user@host -----------------------------------------------
# Validates user exists before attempting drop.
#
# Parameters:
#   $1  -- Username (required)
#   $2  -- Host (required, e.g. localhost, 192.168.x.x, %)
#
# Returns:
#   0  -- Dropped successfully
#   1  -- Validation failed or drop failed
mysql_drop_user() {
    local _mysql_du_user="$1"
    local _mysql_du_host="$2"
 
    if [ -z "$_mysql_du_user" ] || [ -z "$_mysql_du_host" ]; then
        warn "Username and host are required."
        return 1
    fi
 
    if ! mysql -u root -se "SELECT COUNT(*) FROM mysql.user WHERE User='${_mysql_du_user}' AND Host='${_mysql_du_host}';" 2>/dev/null | grep -q "^[1-9]"; then
        warn "User '${_mysql_du_user}'@'${_mysql_du_host}' does not exist."
        return 1
    fi
 
    if mysql -u root -se "DROP USER '${_mysql_du_user}'@'${_mysql_du_host}';" 2>/dev/null; then
        info "Dropped '${_mysql_du_user}'@'${_mysql_du_host}'."
        return 0
    else
        error "Failed to drop '${_mysql_du_user}'@'${_mysql_du_host}'."
        return 1
    fi
}
 
# --- Drop all host entries for a username ------------------------------------
# Drops every host entry for the given username.
#
# Parameters:
#   $1  -- Username (required)
#
# Returns:
#   0  -- All entries dropped successfully
#   1  -- Validation failed or one or more drops failed
mysql_drop_all_users_with_username() {
    local _mysql_du_user="$1"

    if [ -z "$_mysql_du_user" ]; then
        warn "Username is required."
        return 1
    fi

    local _mysql_du_sql="DROP USER"
    local _mysql_du_first=true
    while IFS=$'\t' read -r _mysql_du_u _mysql_du_h; do
        [ "$_mysql_du_u" = "$_mysql_du_user" ] || continue
        [ "$_mysql_du_first" = true ] && _mysql_du_first=false || _mysql_du_sql+=","
        _mysql_du_sql+=" '${_mysql_du_u}'@'${_mysql_du_h}'"
    done <<< "$(_mysql_du_get_users)"

    if [ "$_mysql_du_first" = true ]; then
        warn "No entries found for user '$_mysql_du_user'."
        return 1
    fi

    mysql -u root -se "${_mysql_du_sql};" 2>/dev/null && \
        mysql -u root -se "FLUSH PRIVILEGES;" 2>/dev/null || { error "Failed to drop user '$_mysql_du_user'."; return 1; }

    info "All entries for '$_mysql_du_user' dropped."
}
 
# --- Drop all users for a host -----------------------------------------------
# Drops every user entry for the given host.
#
# Parameters:
#   $1  -- Host (required)
#
# Returns:
#   0  -- All entries dropped successfully
#   1  -- Validation failed or one or more drops failed
mysql_drop_all_users_with_host() {
    local _mysql_du_host="$1"

    if [ -z "$_mysql_du_host" ]; then
        warn "Host is required."
        return 1
    fi

    local _mysql_du_sql="DROP USER"
    local _mysql_du_first=true
    while IFS=$'\t' read -r _mysql_du_u _mysql_du_h; do
        [ "$_mysql_du_h" = "$_mysql_du_host" ] || continue
        [ "$_mysql_du_first" = true ] && _mysql_du_first=false || _mysql_du_sql+=","
        _mysql_du_sql+=" '${_mysql_du_u}'@'${_mysql_du_h}'"
    done <<< "$(_mysql_du_get_users)"

    if [ "$_mysql_du_first" = true ]; then
        warn "No users found for host '$_mysql_du_host'."
        return 1
    fi

    mysql -u root -se "${_mysql_du_sql};" 2>/dev/null && \
        mysql -u root -se "FLUSH PRIVILEGES;" 2>/dev/null || { error "Failed to drop users for host '$_mysql_du_host'."; return 1; }

    info "All users for host '$_mysql_du_host' dropped."
}