#!/bin/bash
# =============================================================================
# modules/services/mysql/actions/mysql_status.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Action ------------------------------------------------------------------
action_mysql_status() {

    
    section "MySQL Status"

    # --- State ---------------------------------------------------------------
    if ! is_mysql_installed; then
        echo -e "  ${BOLD}State:${NC}          $(colorize_status "not installed")"
        return 0
    elif ! is_mysql_running; then
        echo -e "  ${BOLD}State:${NC}          $(colorize_status "stopped")"
    else
        echo -e "  ${BOLD}State:${NC}          $(colorize_status "running")"
    fi

    echo -e "  ${BOLD}Version:${NC}        $(mysql --version 2>/dev/null | awk '{print $3}')"

    if systemctl is-enabled --quiet mysql; then
        echo -e "  ${BOLD}Boot start:${NC}     ${GREEN}enabled${NC}"
    else
        echo -e "  ${BOLD}Boot start:${NC}     ${YELLOW}disabled${NC}"
    fi

    # --- Configuration -------------------------------------------------------
    echo ""
    echo -e "  ${BOLD}Configuration:${NC}"
    echo ""

    local _mysql_st_bind _mysql_st_port _mysql_st_maxconn _mysql_st_bufpool
    _mysql_st_bind=$(mysql -u root -se "SHOW VARIABLES LIKE 'bind_address';" 2>/dev/null | awk '{print $2}')
    _mysql_st_port=$(mysql -u root -se "SHOW VARIABLES LIKE 'port';" 2>/dev/null | awk '{print $2}')
    _mysql_st_maxconn=$(mysql -u root -se "SHOW VARIABLES LIKE 'max_connections';" 2>/dev/null | awk '{print $2}')
    _mysql_st_bufpool=$(mysql -u root -se "SHOW VARIABLES LIKE 'innodb_buffer_pool_size';" 2>/dev/null | awk '{print $2}' | awk '{printf "%.0f MB", $1/1024/1024}')

    echo "    Bind address:       ${_mysql_st_bind:-unknown}"
    echo "    Port:               ${_mysql_st_port:-unknown}"
    echo "    Max connections:    ${_mysql_st_maxconn:-unknown}"
    echo "    InnoDB buffer pool: ${_mysql_st_bufpool:-unknown}"

    if ! is_mysql_running; then
        echo ""
        warn "MySQL is not running -- database and user information unavailable."
        return 0
    fi

    # --- Runtime stats -------------------------------------------------------
    echo ""
    echo -e "  ${BOLD}Runtime:${NC}"
    echo ""

    local _mysql_st_uptime _mysql_st_threads _mysql_st_queries _mysql_st_slow
    _mysql_st_uptime=$(mysql -u root -se "SHOW STATUS LIKE 'Uptime';" 2>/dev/null | awk '{printf "%d hrs %d mins", $2/3600, ($2%3600)/60}')
    _mysql_st_threads=$(mysql -u root -se "SHOW STATUS LIKE 'Threads_connected';" 2>/dev/null | awk '{print $2}')
    _mysql_st_queries=$(mysql -u root -se "SHOW STATUS LIKE 'Queries';" 2>/dev/null | awk '{print $2}')
    _mysql_st_slow=$(mysql -u root -se "SHOW STATUS LIKE 'Slow_queries';" 2>/dev/null | awk '{print $2}')

    echo "    Uptime:             ${_mysql_st_uptime:-unknown}"
    echo "    Threads connected:  ${_mysql_st_threads:-0}"
    echo "    Total queries:      ${_mysql_st_queries:-0}"
    echo "    Slow queries:       ${_mysql_st_slow:-0}"

    # --- Databases -----------------------------------------------------------
    echo ""
    echo -e "  ${BOLD}Databases:${NC}"
    echo ""

    local _mysql_st_dbs
    _mysql_st_dbs=$(mysql -u root -se "SELECT table_schema, ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) FROM information_schema.tables WHERE table_schema NOT IN ('information_schema','performance_schema','sys','mysql') GROUP BY table_schema;" 2>/dev/null)

    if [ -z "$_mysql_st_dbs" ]; then
        echo "    No user databases found."
    else
        printf "    %-30s %s\n" "Database" "Size"
        printf "    %-30s %s\n" "------------------------------" "----------"
        echo "$_mysql_st_dbs" | while IFS=$'\t' read -r _mysql_st_db _mysql_st_size; do
            printf "    %-30s %s MB\n" "$_mysql_st_db" "${_mysql_st_size:-0}"
        done
    fi

    # --- Users ---------------------------------------------------------------
    echo ""
    echo -e "  ${BOLD}Users:${NC}"
    echo ""

    local _mysql_st_users
    _mysql_st_users=$(mysql -u root -se "SELECT User, Host, plugin FROM mysql.user WHERE User NOT IN ('mysql.sys','mysql.session','mysql.infoschema','root') ORDER BY User;" 2>/dev/null)

    if [ -z "$_mysql_st_users" ]; then
        echo "    No non-root users found."
    else
        printf "    %-20s %-20s %s\n" "User" "Host" "Auth Plugin"
        printf "    %-20s %-20s %s\n" "--------------------" "--------------------" "--------------------"
        echo "$_mysql_st_users" | while IFS=$'\t' read -r _mysql_st_user _mysql_st_host _mysql_st_plugin; do
            printf "    %-20s %-20s %s\n" "$_mysql_st_user" "$_mysql_st_host" "$_mysql_st_plugin"
        done
    fi

    echo ""
}

# --- Register ----------------------------------------------------------------
register_action "MySQL Status|mysql_status|action_mysql_status"