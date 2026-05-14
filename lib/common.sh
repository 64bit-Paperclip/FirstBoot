#!/bin/bash
# =============================================================================
# lib/common.sh — Shared Functions & Utilities
# Sourced by firstboot.sh and all modules
# Do not run directly
#
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

strip_escape_codes() {
    echo -e "$1" | sed 's/\x1B\[[0-9;]*[mGKHF]//g'
}


get_ssh_port() {
    local port
    port=$(grep "^Port" /etc/ssh/sshd_config | awk '{print $2}')
    echo "${port:-22}"
}

get_hostname()    { hostname; }
get_os()          { lsb_release -ds 2>/dev/null || echo "Unknown"; }
get_os_version()  { lsb_release -rs 2>/dev/null || echo "Unknown"; }
get_ipv4()        { curl -4 -s --max-time 5 ifconfig.me 2>/dev/null || echo "unknown"; }
get_ipv6()        { curl -6 -s --max-time 5 ifconfig.me 2>/dev/null || echo "unknown"; }
get_uptime()      { uptime -p 2>/dev/null | sed 's/up //' || echo "unknown"; }
get_ram_total()   { free -h | awk '/^Mem:/{print $2}'; }
get_ram_free()    { free -h | awk '/^Mem:/{print $4}'; }
get_disk_total()  { df -h / | awk 'NR==2{print $2}'; }
get_disk_free()   { df -h / | awk 'NR==2{print $4}'; }
get_load()        { uptime | awk -F'load average:' '{print $2}' | xargs; }
get_cpu_cores()   { nproc 2>/dev/null || echo "unknown"; }


get_client_ssh_ip() { 
    local ip
    ip=$(echo "$SSH_CLIENT" | awk '{print $1}' | tr -d '()')
    echo "${ip:-unknown}"
}

# Check if current user is logged in directly as root
is_user_root() {
    [ "$UID" -eq 0 ]
}

# Check if current user has sudo privileges
is_user_super_user() {
    [ "$EUID" -eq 0 ]
}

is_firstboot_running_installed() {
    [ "$FIRSTBOOT_RUN_DIR" = "$FIRSTBOOT_INSTALL_DIR" ]
}

is_firstboot_running_portable() {
    ! is_firstboot_running_installed
}

has_sudo_users() {
    getent group sudo | cut -d: -f4 | tr ',' '\n' | grep -q .
}

run_system_cmd() {
    local output
    local cmd="$@"
    
    output=$(eval "$cmd" 2>&1)
    local exit_code=$?
    
    if [ $exit_code -ne 0 ]; then
        echo "[!] Command failed: $cmd"
        read -p "    Would you like to see the output? [y/N]: " show
        if [[ "$show" =~ ^[Yy]$ ]]; then
            echo "$output"
        fi
    fi
    
    return $exit_code
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


}