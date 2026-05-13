#!/bin/bash
# =============================================================================
# firstboot.sh — Master Server Setup Script
# Ubuntu 24.04 LTS — Linode
# 
#
# Usage:
#   sudo bash firstboot.sh
#
# =============================================================================

# --- Strict mode (master level) ----------------------------------------------
# We do NOT use set -e here because we want to handle module failures
# individually rather than aborting the entire run.
set -uo pipefail

# --- Must run as super user ---------------------------------------------------
[ "$EUID" -ne 0 ] && echo "[✗] Please run as a Super User: sudo bash firstboot.sh" && exit 1

# --- Resolve default directories ----------------------------------------------
# Works regardless of where you call the script from

# --- Directory Info -----------------------------------------------------------
FIRSTBOOT_RUN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FIRSTBOOT_INSTALL_DIR="/opt/firstboot"

# --- Run Mode Dependant Directories -------------------------------------------
if [ "$FIRSTBOOT_RUN_DIR" = "$FIRSTBOOT_INSTALL_DIR" ]; then
    FIRSTBOOT_LOG_DIR="/var/log/firstboot"
    FIRSTBOOT_USER_DIR="/etc/firstboot"
else
    FIRSTBOOT_LOG_DIR="$FIRSTBOOT_RUN_DIR/logs/"
    FIRSTBOOT_USER_DIR="$FIRSTBOOT_RUN_DIR/user"
fi

FIRSTBOOT_LOG_FILE="$FIRSTBOOT_LOG_DIR/firstboot-$(date +%Y%m%d-%H%M%S).log"

LIB_DIR="$FIRSTBOOT_RUN_DIR/lib"
MODULE_DIR="$FIRSTBOOT_RUN_DIR/modules"
SERVICE_GROUPS_DIR="$MODULE_DIR/groups"
SERVICES_DIR="$MODULE_DIR/services"
ACTIONS_DIR="$MODULE_DIR/actions"

USER_MODULES_DIR="$FIRSTBOOT_USER_DIR/modules"
USER_GROUPS_DIR="$USER_MODULES_DIR/groups"
USER_SERVICES_DIR="$USER_MODULES_DIR/services"
USER_ACTIONS_DIR="$USER_MODULES_DIR/actions"

# --- Verify directory structure ----------------------------------------------
[ ! -d "$LIB_DIR" ]              && echo "[x] Cannot find lib/ directory. Expected at: $LIB_DIR" && exit 1
[ ! -f "$LIB_DIR/globals.sh" ]   && echo "[x] Cannot find lib/globals.sh. Expected at: $LIB_DIR/globals.sh" && exit 1
[ ! -f "$LIB_DIR/common.sh" ]    && echo "[x] Cannot find lib/common.sh. Expected at: $LIB_DIR/common.sh" && exit 1
[ ! -f "$LIB_DIR/logging.sh" ]   && echo "[x] Cannot find lib/logging.sh. Expected at: $LIB_DIR/logging.sh" && exit 1
[ ! -f "$LIB_DIR/ui.sh" ]        && echo "[x] Cannot find lib/ui.sh. Expected at: $LIB_DIR/ui.sh" && exit 1
[ ! -f "$LIB_DIR/groups.sh" ]    && echo "[x] Cannot find lib/groups.sh. Expected at: $LIB_DIR/groups.sh" && exit 1
[ ! -f "$LIB_DIR/services.sh" ]  && echo "[x] Cannot find lib/services.sh. Expected at: $LIB_DIR/services.sh" && exit 1
[ ! -f "$LIB_DIR/actions.sh" ]   && echo "[x] Cannot find lib/actions.sh. Expected at: $LIB_DIR/actions.sh" && exit 1
[ ! -f "$LIB_DIR/status.sh" ]    && echo "[x] Cannot find lib/status.sh. Expected at: $LIB_DIR/status.sh" && exit 1
[ ! -d "$MODULE_DIR" ]           && echo "[x] Cannot find modules/ directory. Expected at: $MODULE_DIR" && exit 1
[ ! -d "$SERVICE_GROUPS_DIR" ]   && echo "[x] Cannot find modules/groups/ directory. Expected at: $SERVICE_GROUPS_DIR" && exit 1
[ ! -d "$SERVICES_DIR" ]         && echo "[x] Cannot find modules/services/ directory. Expected at: $SERVICES_DIR" && exit 1
[ ! -d "$ACTIONS_DIR" ]          && echo "[x] Cannot find modules/actions/ directory. Expected at: $ACTIONS_DIR" && exit 1

# --- Ensure required directories exist ---------------------------------------
mkdir -p "$FIRSTBOOT_LOG_DIR" || { echo "[x] Cannot create log directory: $FIRSTBOOT_LOG_DIR"; exit 1; }
mkdir -p "$FIRSTBOOT_USER_DIR" || { echo "[x] Cannot create user directory: $FIRSTBOOT_USER_DIR"; exit 1; }
mkdir -p "$USER_MODULES_DIR" || { echo "[x] Cannot create user directory: $USER_MODULES_DIR"; exit 1; }
mkdir -p "$USER_SERVICES_DIR" || { echo "[x] Cannot create user directory: $USER_SERVICES_DIR"; exit 1; }
mkdir -p "$USER_ACTIONS_DIR" || { echo "[x] Cannot create user directory: $USER_ACTIONS_DIR"; exit 1; }

# --- Load required common libs -----------------------------------------------
source "$LIB_DIR/globals.sh"
source "$LIB_DIR/common.sh"
source "$LIB_DIR/logging.sh"
source "$LIB_DIR/ui.sh"

# --- Root User Check / Warning -----------------------------------------------
if is_user_root; then
    echo ""
    warn "You are currently logged in and running FirstBoot as root."
    confirm_prompt "${GREEN}Are you sure you wish to contnue?${NC}" || { exit 1;}
    echo ""
fi

# --- Portable Check / Warning -----------------------------------------------
if is_firstboot_running_portable; then
    echo ""
    warn "You are running FirstBoot in portable mode. Some Features may not be available."
    echo "-------------------------------------------------------------------------------"
    echo "  Log files will be placed in:"
    echo -e "      ${CYAN}$FIRSTBOOT_LOG_DIR${NC}"
    echo "  User defined modules, scripts, and data are loaded from:"
    echo -e "      ${CYAN}$FIRSTBOOT_USER_DIR${NC}"
    echo "-------------------------------------------------------------------------------"
    confirm_prompt "${GREEN}Are you sure you wish to contnue?${NC}" || { exit 1;}
    echo ""
fi




# --- Load Modules ------------------------------------------------------------
source "$LIB_DIR/groups.sh"
source "$LIB_DIR/services.sh"
source "$LIB_DIR/actions.sh"
source "$LIB_DIR/status.sh"

# --- Source all modules ------------------------------------------------------
source_groups
source_services
source_actions

# --- Banner ------------------------------------------------------------------
draw_banner
log "info" "FirstBoot Started"

# --- Status ------------------------------------------------------------------
show_status

MAIN_MENU_OPTIONS=(
    "---|System Setup"
    "Harden System|show_status"
    "---|System Management"
    "System Status|show_status"
    "Manage Runtimes|show_status"
    "Manage Service Groups|groups_menu"
	"Manage Service|services_menu"
	"Manage Users|show_status"
	"Run Individual Action|draw_actions_menu"
    "---|FirstBoot"
    "Settings|show_status"
	"View Logs|show_status"
)
command_menu MAIN_MENU_OPTIONS "Main Menu"

