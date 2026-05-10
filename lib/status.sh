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
    local svc="$1"
    local pkg="${2:-$1}"
    if ! pkg_installed "$pkg" 2>/dev/null; then
        echo "not installed"
    elif systemctl is-active --quiet "$svc" 2>/dev/null; then
        echo "running"
    else
        echo "stopped"
    fi
}

# --- Helper: colorize status string ------------------------------------------
colorize() {
    case "$1" in
        "running")       echo -e "${GREEN}running${NC}" ;;
        "stopped")       echo -e "${YELLOW}stopped${NC}" ;;
        "not installed") echo -e "${RED}not installed${NC}" ;;
        "installed")     echo -e "${GREEN}installed${NC}" ;;
        *)               echo "$1" ;;
    esac
}

# --- Gather system info ------------------------------------------------------
SYS_HOSTNAME=$(hostname)
SYS_OS=$(lsb_release -ds 2>/dev/null || echo "Unknown")
SYS_IP=$(curl -s ifconfig.me)
SYS_UPTIME=$(uptime -p 2>/dev/null | sed 's/up //' || echo "Unknown")
SYS_RAM=$(free -h | awk '/^Mem:/{print $2}')
SYS_DISK=$(df -h / | awk 'NR==2{print $4}')
SYS_LOAD=$(uptime | awk -F'load average:' '{print $2}' | xargs)

# --- Service list (name, service, package) -----------------------------------
# Format: "Display Name|service-name|package-name"
SERVICES=(
    "Apache|apache2|apache2"
    "Certbot|certbot|certbot"
    "Docker|docker|docker-ce"
    "Dovecot|dovecot|dovecot-core"
    "Fail2ban|fail2ban|fail2ban"
    "MongoDB|mongod|mongodb-org"
    "MySQL|mysql|mysql-server"
    "Nginx|nginx|nginx"
    "Node.js|node|nodejs"
    "OpenDKIM|opendkim|opendkim"
    "PHP-FPM|php-fpm|php-fpm"
    "PostgreSQL|postgresql|postgresql"
    "Postfix|postfix|postfix"
    "Redis|redis-server|redis-server"
    "Rspamd|rspamd|rspamd"
    "Supervisor|supervisor|supervisor"
    "UFW|ufw|ufw"
)

# --- Build status array ------------------------------------------------------
declare -a SVC_LABELS
declare -a SVC_STATUSES

for entry in "${SERVICES[@]}"; do
    IFS='|' read -r label svc pkg <<< "$entry"
    status=$(svc_status "$svc" "$pkg")
    # Special case: certbot has no service, just check if installed
    if [ "$label" = "Certbot" ] || [ "$label" = "Node.js" ]; then
        pkg_installed "$pkg" && status="installed" || status="not installed"
    fi
    SVC_LABELS+=("$label")
    SVC_STATUSES+=("$status")
done

# --- Display -----------------------------------------------------------------
section "System Status"

echo -e "  ${BOLD}Hostname:${NC}  $SYS_HOSTNAME"
echo -e "  ${BOLD}OS:${NC}        $SYS_OS"
echo -e "  ${BOLD}IP:${NC}        $SYS_IP"
echo -e "  ${BOLD}Uptime:${NC}    $SYS_UPTIME"
echo -e "  ${BOLD}RAM:${NC}       $SYS_RAM total"
echo -e "  ${BOLD}Disk:${NC}      $SYS_DISK free"
echo -e "  ${BOLD}Load:${NC}      $SYS_LOAD"
echo ""
echo -e "  ${BOLD}Services:${NC}"
echo ""

# 3 columns, each column is 26 chars wide (fits in 80 chars with 2 char margin)
COL_WIDTH=26
COLS=3
COUNT=${#SVC_LABELS[@]}
ROWS=$(( (COUNT + COLS - 1) / COLS ))

for (( row=0; row<ROWS; row++ )); do
    printf "  "
    for (( col=0; col<COLS; col++ )); do
        idx=$(( row + col * ROWS ))
        if [ $idx -lt $COUNT ]; then
            label="${SVC_LABELS[$idx]}:"
            status="${SVC_STATUSES[$idx]}"
            colored=$(colorize "$status")
            # Printf with fixed width for label, color applied after
            printf "%-14s %s" "$label" "$colored"
            # Pad to column width (accounting for invisible color codes)
            pad=$(( COL_WIDTH - ${#label} - ${#status} - 1 ))
            printf "%${pad}s" ""
        fi
    done
    echo ""
done

echo ""
echo "  ── Press any key to continue ────────────────────────"
read -rn1