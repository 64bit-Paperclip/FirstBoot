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
echo "Detecting current IP..."

CURRENT_IP=$(echo "${SSH_CONNECTION:-}" | awk '{print $1}')
if [ -z "$CURRENT_IP" ]; then
    warn "Could not auto-detect your SSH session IP."
    read -rp "  Enter your current IP to whitelist for SSH: " CURRENT_IP
fi
info "Your IP detected as: ${BOLD}$CURRENT_IP${NC}"
export CURRENT_IP

# --- Server identity ---------------------------------------------------------
section "Server Identity"
 
read -rp "  Short name for this server (e.g. mail, db, web): " SERVER_NAME
read -rp "  Hostname (e.g. mail.example.com): " SERVER_HOSTNAME
export SERVER_NAME SERVER_HOSTNAME
 
# Set hostname
hostnamectl set-hostname "$SERVER_HOSTNAME"