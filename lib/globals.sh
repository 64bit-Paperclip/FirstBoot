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

# --- Colors ------------------------------------------------------------------
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'

# --- Bold colors -------------------------------------------------------------
BOLD_BLACK='\033[1;30m'
BOLD_RED='\033[1;31m'
BOLD_GREEN='\033[1;32m'
BOLD_YELLOW='\033[1;33m'
BOLD_BLUE='\033[1;34m'
BOLD_MAGENTA='\033[1;35m'
BOLD_CYAN='\033[1;36m'
BOLD_WHITE='\033[1;37m'

# --- Dim colors --------------------------------------------------------------
DIM_BLACK='\033[2;30m'
DIM_RED='\033[2;31m'
DIM_GREEN='\033[2;32m'
DIM_YELLOW='\033[2;33m'
DIM_BLUE='\033[2;34m'
DIM_MAGENTA='\033[2;35m'
DIM_CYAN='\033[2;36m'
DIM_WHITE='\033[2;37m'

# --- Background colors -------------------------------------------------------
BG_BLACK='\033[40m'
BG_RED='\033[41m'
BG_GREEN='\033[42m'
BG_YELLOW='\033[43m'
BG_BLUE='\033[44m'
BG_MAGENTA='\033[45m'
BG_CYAN='\033[46m'
BG_WHITE='\033[47m'

# --- Formatting --------------------------------------------------------------
BOLD='\033[1m'
DIM='\033[2m'
ITALIC='\033[3m'
UNDERLINE='\033[4m'
BLINK='\033[5m'
REVERSE='\033[7m'
STRIKETHROUGH='\033[9m'

# --- Reset -------------------------------------------------------------------
NC='\033[0m'

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







