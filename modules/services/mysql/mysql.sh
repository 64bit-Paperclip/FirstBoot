#!/bin/bash
# =============================================================================
# modules/mysql.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# TODO: not yet implemented
# =============================================================================

# --- Source actions ----------------------------------------------------------
MYSQL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for _file in "$MYSQL_DIR/actions"/*.sh; do
    [ -f "$_file" ] && source "$_file"
done
unset _file MYSQL_DIR

# --- Entry function ----------------------------------------------------------
mysql_entry() {
    # TODO: not yet implemented
    warn "MySQL service not yet implemented"
}

# --- Register ----------------------------------------------------------------
register_service "MySQL|mysql|mysql-server|SVC_MYSQL|database|mysql_entry"