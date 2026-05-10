#!/bin/bash
# =============================================================================
# lib/globals.sh — Global Variables & Detection Functions
# Sourced by firstboot.sh after SCRIPT_DIR/LIB_DIR/MODULE_DIR are set
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# =============================================================================
# VARIABLES
# =============================================================================

# --- Colors & formatting -----------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# --- Logging -----------------------------------------------------------------
LOG_DIR="/var/log/firstboot"
LOG_FILE="$LOG_DIR/firstboot-$(date +%Y%m%d-%H%M%S).log"

# --- Session -----------------------------------------------------------------
CURRENT_IP=""
ADMIN_USER=""
SERVER_NAME=""
SERVER_HOSTNAME=""

# --- System info (populated by detect_system) --------------------------------
SYS_HOSTNAME=""
SYS_OS=""
SYS_OS_VERSION=""
SYS_IPV4=""
SYS_IPV6=""
SYS_UPTIME=""
SYS_RAM_TOTAL=""
SYS_RAM_FREE=""
SYS_DISK_TOTAL=""
SYS_DISK_FREE=""
SYS_LOAD=""
SYS_CPU_CORES=""

# --- Groups ------------------------------------------------------------------
# Populated by each group module when sourced at startup
# Format: "Label|name|entry_fn"
SERVICE_GROUPS=()

# --- Services ----------------------------------------------------------------
# Populated by each service module when sourced at startup
# Format: "Label|service|package|SVC_var|groups|entry_fn"
SERVICES=()

# --- Actions -----------------------------------------------------------------
# Populated by modules when sourced at startup
# Format: "Label|name|entry_fn"
ACTIONS=()




# =============================================================================
# DETECTION FUNCTIONS
# =============================================================================

# --- detect_system -----------------------------------------------------------
detect_system() {
    SYS_HOSTNAME=$(hostname)
    SYS_OS=$(lsb_release -ds 2>/dev/null || echo "Unknown")
    SYS_OS_VERSION=$(lsb_release -rs 2>/dev/null || echo "Unknown")
    SYS_IPV4=$(curl -4 -s --max-time 5 ifconfig.me 2>/dev/null || echo "unknown")
    SYS_IPV6=$(curl -6 -s --max-time 5 ifconfig.me 2>/dev/null || echo "unknown")
    SYS_UPTIME=$(uptime -p 2>/dev/null | sed 's/up //' || echo "unknown")
    SYS_RAM_TOTAL=$(free -h | awk '/^Mem:/{print $2}')
    SYS_RAM_FREE=$(free -h | awk '/^Mem:/{print $4}')
    SYS_DISK_TOTAL=$(df -h / | awk 'NR==2{print $2}')
    SYS_DISK_FREE=$(df -h / | awk 'NR==2{print $4}')
    SYS_LOAD=$(uptime | awk -F'load average:' '{print $2}' | xargs)
    SYS_CPU_CORES=$(nproc 2>/dev/null || echo "unknown")
}

# --- detect_session ----------------------------------------------------------
detect_session() {
    CURRENT_IP=$(who am i | awk '{print $5}' | tr -d '()')
    [ -z "$CURRENT_IP" ] && CURRENT_IP="unknown"


}





# =============================================================================
# EXPORTS
# =============================================================================

export RED GREEN YELLOW CYAN BOLD NC

export LOG_DIR LOG_FILE
export FIRSTBOOT_COMPLETE FIRSTBOOT_LAST_RUN
export CURRENT_IP ADMIN_USER SERVER_NAME SERVER_HOSTNAME
export SYS_HOSTNAME SYS_OS SYS_OS_VERSION SYS_IPV4 SYS_IPV6
export SYS_UPTIME SYS_RAM_TOTAL SYS_RAM_FREE SYS_DISK_TOTAL SYS_DISK_FREE
export SYS_LOAD SYS_CPU_CORES
export SERVICE_GROUPS SERVICES ACTIONS



export -f detect_system detect_session