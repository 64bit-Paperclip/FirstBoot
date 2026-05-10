#!/bin/bash
# =============================================================================
# lib/status.sh — System Status Display
# Sourced by firstboot.sh at startup
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Helper: check if a package is installed ---------------------------------
pkg_installed() {
    dpkg -l "$1" 2>/dev/null | grep -q "^ii"
}

# --- Helper: check if a service is running -----------------------------------
svc_status() {
    local name="$1"
    if ! pkg_installed "$name" 2>/dev/null; then
        echo -e "${RED}not installed${NC}"
    elif systemctl is-active --quiet "$name" 2>/dev/null; then
        echo -e "${GREEN}running${NC}"
    else
        echo -e "${YELLOW}installed, stopped${NC}"
    fi
}

# --- Gather system info ------------------------------------------------------
SYS_HOSTNAME=$(hostname)
SYS_OS=$(lsb_release -ds 2>/dev/null || echo "Unknown")
SYS_IP=$(echo "${SSH_CONNECTION:-}" | awk '{print $3}')
SYS_UPTIME=$(uptime -p 2>/dev/null || echo "Unknown")
SYS_RAM=$(free -h | awk '/^Mem:/{print $2}')
SYS_DISK=$(df -h / | awk 'NR==2{print $4}')
SYS_LOAD=$(uptime | awk -F'load average:' '{print $2}' | xargs)

# --- Display -----------------------------------------------------------------
section "System Status"

echo -e "  ${BOLD}System:${NC}"
echo    "    Hostname:   $SYS_HOSTNAME"
echo    "    OS:         $SYS_OS"
echo    "    Public IP:  ${CURRENT_IP:-unknown}"
echo    "    Uptime:     $SYS_UPTIME"
echo    "    RAM:        $SYS_RAM total"
echo    "    Disk:       $SYS_DISK free on /"
echo    "    Load:       $SYS_LOAD"
echo ""
echo -e "  ${BOLD}Services:${NC}"
printf  "    %-20s %s\n" "Postfix:"    "$(svc_status postfix)"
printf  "    %-20s %s\n" "Dovecot:"    "$(svc_status dovecot)"
printf  "    %-20s %s\n" "MySQL:"      "$(svc_status mysql)"
printf  "    %-20s %s\n" "Nginx:"      "$(svc_status nginx)"
printf  "    %-20s %s\n" "Certbot:"    "$(pkg_installed certbot && echo -e "${GREEN}installed${NC}" || echo -e "${RED}not installed${NC}")"
printf  "    %-20s %s\n" "Rspamd:"     "$(svc_status rspamd)"
printf  "    %-20s %s\n" "Redis:"      "$(svc_status redis-server)"
printf  "    %-20s %s\n" "Fail2ban:"   "$(svc_status fail2ban)"
printf  "    %-20s %s\n" "UFW:"        "$(svc_status ufw)"
printf  "    %-20s %s\n" "OpenDKIM:"   "$(svc_status opendkim)"
echo ""
echo "  ── Press any key to continue ────────────────────────"
read -rn1