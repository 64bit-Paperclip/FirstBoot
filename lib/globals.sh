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

# --- Logging -----------------------------------------------------------------
LOG_DIR="/var/log/firstboot"
LOG_FILE="$LOG_DIR/firstboot-$(date +%Y%m%d-%H%M%S).log"

# --- Firstboot state ---------------------------------------------------------
FIRSTBOOT_COMPLETE=false
FIRSTBOOT_LAST_RUN=""

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

# --- Services ----------------------------------------------------------------
# Populated by each module when sourced at startup
# Format: "Label|service|package|SVC_var|groups|install_fn|uninstall_fn|configure_fn|check_fn"
SERVICES=()

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

# Check if a package is installed
pkg_installed() {
    dpkg -l "$1" 2>/dev/null | grep -q "^ii"
}

# Check if a service is active
svc_running() {
    systemctl is-active --quiet "$1" 2>/dev/null
}

# Get installed version of a package
pkg_version() {
    dpkg -l "$1" 2>/dev/null | awk '/^ii/{print $3}' | head -1
}

# Check if a service is installed based on its SVC_ variable
is_installed() {
    local svcvar="$1"
    [ "${!svcvar}" != "not installed" ]
}

# Check if a service is running based on its SVC_ variable
is_running() {
    local svcvar="$1"
    [ "${!svcvar}" = "running" ]
}

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

    if [ -f /etc/firstboot.complete ]; then
        FIRSTBOOT_COMPLETE=true
        FIRSTBOOT_LAST_RUN=$(cat /etc/firstboot.complete)
    fi
}

# --- detect_services ---------------------------------------------------------
# Loops over SERVICES array, checks each package/service, updates SVC_* vars
detect_services() {
    local label svc pkg svcvar groups install_fn uninstall_fn configure_fn check_fn

    for entry in "${SERVICES[@]}"; do
        IFS='|' read -r label svc pkg svcvar groups install_fn uninstall_fn configure_fn check_fn <<< "$entry"

        if ! pkg_installed "$pkg"; then
            declare -g "${svcvar}=not installed"
        elif svc_running "$svc"; then
            declare -g "${svcvar}=running"
        else
            declare -g "${svcvar}=stopped"
        fi
    done
}

# --- detect_all --------------------------------------------------------------
detect_all() {
    detect_system
    detect_session
    detect_services
}

# =============================================================================
# EXPORTS
# =============================================================================

export LOG_DIR LOG_FILE
export FIRSTBOOT_COMPLETE FIRSTBOOT_LAST_RUN
export CURRENT_IP ADMIN_USER SERVER_NAME SERVER_HOSTNAME
export SYS_HOSTNAME SYS_OS SYS_OS_VERSION SYS_IPV4 SYS_IPV6
export SYS_UPTIME SYS_RAM_TOTAL SYS_RAM_FREE SYS_DISK_TOTAL SYS_DISK_FREE
export SYS_LOAD SYS_CPU_CORES
export SERVICES

export -f pkg_installed svc_running pkg_version is_installed is_running
export -f detect_system detect_session detect_services detect_all