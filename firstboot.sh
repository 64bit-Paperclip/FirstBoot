#!/bin/bash
# =============================================================================
# firstboot.sh — Master Server Setup Script
# Ubuntu 24.04 LTS — Linode
# 
#
# Usage:
#   sudo bash firstboot.sh
#
# Directory structure expected:
#   firstboot.sh
#   lib/
#     common.sh
#   modules/
#     hardening.sh
#     firewall.sh
#     certbot.sh
#     mysql.sh
#     postfix.sh
#     dovecot.sh
#     opendkim.sh
#     rspamd.sh
#     web.sh
# =============================================================================

# --- Strict mode (master level) ----------------------------------------------
# We do NOT use set -e here because we want to handle module failures
# individually rather than aborting the entire run.
set -uo pipefail

# --- Must run as root --------------------------------------------------------
[ "$EUID" -ne 0 ] && echo "[✗] Please run as root: sudo bash firstboot.sh" && exit 1

# --- Resolve script directory ------------------------------------------------
# Works regardless of where you call the script from
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"
MODULE_DIR="$SCRIPT_DIR/modules"

# --- Verify directory structure ----------------------------------------------
[ ! -d "$LIB_DIR" ]            && echo "[✗] Cannot find lib/ directory. Expected at: $LIB_DIR" && exit 1
[ ! -f "$LIB_DIR/common.sh" ]  && echo "[✗] Cannot find lib/common.sh. Expected at: $LIB_DIR/common.sh" && exit 1
[ ! -d "$MODULE_DIR" ]         && echo "[✗] Cannot find modules/ directory. Expected at: $MODULE_DIR" && exit 1

# --- Load common libs --------------------------------------------------------
source "$LIB_DIR/common.sh"

# --- Logging setup -----------------------------------------------------------
LOG_DIR="/var/log/firstboot"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/firstboot-$(date +%Y%m%d-%H%M%S).log"

# Tee all output to log file while still showing on terminal
exec > >(tee -a "$LOG_FILE") 2>&1

info "Logging to: $LOG_FILE"

# --- Banner ------------------------------------------------------------------
echo ""
echo -e "${CYAN}${BOLD}"
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║         Server FirstBoot & Setup Toolkit         ║"
echo "  ║              Ubuntu 24.04 LTS — Linode           ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo -e "${NC}"


# --- Detect SSH session IP ---------------------------------------------------
CURRENT_IP=$(who am i | awk '{print $5}' | tr -d '()')

if [ -z "$CURRENT_IP" ]; then
    warn "Could not auto-detect your SSH session IP."
    read -rp "  Enter your current IP to whitelist for SSH: " CURRENT_IP
fi

info "Your IP detected as: ${BOLD}$CURRENT_IP${NC}"
export CURRENT_IP

# --- Server short name -------------------------------------------------------
section "Server Identity"

echo "  This is typically the root domain name for this server and its services."
echo "  For example, if your services live under 'example.com' enter 'example.com'"
echo ""

while true; do
    read -rp "  Root domain name: " SERVER_NAME
    [ -n "$SERVER_NAME" ] && break
    warn "Domain name cannot be empty."
done

export SERVER_NAME

# --- Admin user --------------------------------------------------------------
section "Admin User"

while true; do
    while true; do
        read -rp "  New admin username: " ADMIN_USER
        [ -n "$ADMIN_USER" ] && break
        warn "Username cannot be empty."
    done

    if id "$ADMIN_USER" &>/dev/null; then
        warn "User '$ADMIN_USER' already exists."
        if groups "$ADMIN_USER" | grep -q '\bsudo\b'; then
            info "User '$ADMIN_USER' already has sudo access — no changes needed."
            break
        else
            warn "User '$ADMIN_USER' does not have sudo access."
            read -rp "  Grant sudo access to '$ADMIN_USER'? (yes/no): " GRANT_SUDO
            if [ "$GRANT_SUDO" = "yes" ]; then
                usermod -aG sudo "$ADMIN_USER"
                info "Sudo access granted to '$ADMIN_USER'."
                break
            else
                warn "Please enter a different username."
            fi
        fi
    else
        adduser --gecos "" "$ADMIN_USER"
        usermod -aG sudo "$ADMIN_USER"
        info "Created user '$ADMIN_USER' with sudo access."
        break
    fi
done

export ADMIN_USER

# --- Component selection -----------------------------------------------------
section "Select Components"

ROLE_HARDENING=true
ROLE_MAIL=false
ROLE_DB=false
ROLE_WEB=false

HARDENING_DESC="  Installs:  fail2ban, unattended-upgrades, auditd, chrony
  Does:      Hardens SSH, applies sysctl security settings,
             configures firewall (UFW), enables automatic
             security updates and brute force protection."

MAIL_DESC="  Installs:  Postfix, Dovecot, OpenDKIM, Rspamd, Redis, Certbot
  Does:      Virtual mailboxes via MySQL, DKIM signing,
             spam filtering, TLS via Let's Encrypt."

DB_DESC="  Installs:  MySQL 8.0
  Does:      Creates mailserver DB and tables for virtual
             users, domains, and aliases. Restricts access
             to private network only."

WEB_DESC="  Installs:  Nginx, Certbot
  Does:      Configures Nginx for your domain and obtains
             a TLS certificate via Let's Encrypt."

show_menu() {
    echo ""
    [ "$ROLE_HARDENING" = true ] && echo -e "    ${GREEN}[✓]${NC} 1)  Hardening  ${YELLOW}(recommended)${NC}" \
                                 || echo -e "    ${RED}[ ]${NC} 1)  Hardening  ${RED}(not recommended)${NC}"
    [ "$ROLE_MAIL" = true ]      && echo -e "    ${GREEN}[✓]${NC} 2)  Mail" \
                                 || echo    "    [ ] 2)  Mail"
    [ "$ROLE_DB" = true ]        && echo -e "    ${GREEN}[✓]${NC} 3)  Database" \
                                 || echo    "    [ ] 3)  Database"
    [ "$ROLE_WEB" = true ]       && echo -e "    ${GREEN}[✓]${NC} 4)  Web" \
                                 || echo    "    [ ] 4)  Web"
    echo ""
    echo    "         0)  Done"
    echo ""
    echo "  ── Enter a number to toggle, 0 when done ────────────"
}

while true; do
    show_menu
    read -rp "  Selection: " SELECTION

    case "$SELECTION" in
        1)
            if [ "$ROLE_HARDENING" = true ]; then
                ROLE_HARDENING=false
                echo ""
                warn "Hardening deselected — this is not recommended for production servers."
            else
                ROLE_HARDENING=true
                echo ""
                echo -e "${CYAN}  ── Hardening ────────────────────────────────────────${NC}"
                echo "$HARDENING_DESC"
                echo -e "${CYAN}  ────────────────────────────────────────────────────${NC}"
            fi
            ;;
        2)
            if [ "$ROLE_MAIL" = true ]; then
                ROLE_MAIL=false
                echo ""
                info "Mail deselected"
            else
                ROLE_MAIL=true
                echo ""
                echo -e "${CYAN}  ── Mail ────────────────────────────────────────────${NC}"
                echo "$MAIL_DESC"
                echo -e "${CYAN}  ────────────────────────────────────────────────────${NC}"
            fi
            ;;
        3)
            if [ "$ROLE_DB" = true ]; then
                ROLE_DB=false
                echo ""
                info "Database deselected"
            else
                ROLE_DB=true
                echo ""
                echo -e "${CYAN}  ── Database ─────────────────────────────────────────${NC}"
                echo "$DB_DESC"
                echo -e "${CYAN}  ────────────────────────────────────────────────────${NC}"
            fi
            ;;
        4)
            if [ "$ROLE_WEB" = true ]; then
                ROLE_WEB=false
                echo ""
                info "Web deselected"
            else
                ROLE_WEB=true
                echo ""
                echo -e "${CYAN}  ── Web ─────────────────────────────────────────────${NC}"
                echo "$WEB_DESC"
                echo -e "${CYAN}  ────────────────────────────────────────────────────${NC}"
            fi
            ;;
        0)
            if [ "$ROLE_HARDENING" = false ] && [ "$ROLE_MAIL" = false ] && \
               [ "$ROLE_DB" = false ] && [ "$ROLE_WEB" = false ]; then
                warn "No components selected — nothing will be installed."
                read -rp "  Continue anyway? (yes/no): " CONFIRM_EMPTY
                [ "$CONFIRM_EMPTY" = "yes" ] && break
            else
                break
            fi
            ;;
        *)
            warn "Invalid selection — enter 1, 2, 3, 4, or 0"
            ;;
    esac
done

export ROLE_HARDENING ROLE_MAIL ROLE_DB ROLE_WEB

# --- Server identity ---------------------------------------------------------
section "Server Identity"

CURRENT_HOSTNAME=$(hostname)

echo "  Current hostname: $CURRENT_HOSTNAME"
echo ""
echo "  Current /etc/hosts:"
cat /etc/hosts | sed 's/^/    /'
echo ""

if [ "$CURRENT_HOSTNAME" = "localhost" ]; then
    warn "Hostname is 'localhost' and must be changed before continuing."
    read -rp "  Full hostname (e.g. mail.example.com): " SERVER_HOSTNAME
    hostnamectl set-hostname "$SERVER_HOSTNAME"
    echo "127.0.1.1 $SERVER_HOSTNAME ${SERVER_HOSTNAME%%.*}" >> /etc/hosts
    info "Hostname updated to: $SERVER_HOSTNAME"
else
    read -rp "  Update hostname? (yes/no): " UPDATE_HOSTNAME
    if [ "$UPDATE_HOSTNAME" = "yes" ]; then
        read -rp "  Full hostname (e.g. mail.example.com): " SERVER_HOSTNAME
        hostnamectl set-hostname "$SERVER_HOSTNAME"
        echo "127.0.1.1 $SERVER_HOSTNAME ${SERVER_HOSTNAME%%.*}" >> /etc/hosts
        info "Hostname updated to: $SERVER_HOSTNAME"
    else
        SERVER_HOSTNAME="$CURRENT_HOSTNAME"
        info "Keeping existing hostname: $SERVER_HOSTNAME"
    fi
fi

read -rp "  Short name for this server (e.g. mail, db, web): " SERVER_NAME
export SERVER_NAME SERVER_HOSTNAME