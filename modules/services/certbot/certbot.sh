#!/bin/bash
# =============================================================================
# modules/certbot.sh
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# TODO: not yet implemented
# =============================================================================
 
# --- Service variables -------------------------------------------------------
CERTBOT_LABEL="Certbot"
CERTBOT_SERVICE="certbot"
CERTBOT_PACKAGE="certbot"
CERTBOT_SVC_VAR="SVC_CERTBOT"
CERTBOT_GROUP="security,web,mail"
CERTBOT_ENTRY="certbot_entry"

Initialize status variable ----------------------------------------------
SVC_NGINX="not installed"

# --- Directory variables -----------------------------------------------------
CERTBOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CERTBOT_ACTIONS_DIR="$CERTBOT_DIR/actions"
CERTBOT_UTILS_DIR="$CERTBOT_DIR/utilities"



# --- Global Utility Functions ------------------------------------------------
is_certbot_installed(){
    pkg_installed "$CERTBOT_PACKAGE"
}

is_certbot_running(){
    svc_running "$CERTBOT_SERVICE"
}

# --- Entry function ----------------------------------------------------------
certbot_entry() {
    echo "Certbot Controll not yet complete"
    
}

# --- Register ----------------------------------------------------------------
register_service "$CERTBOT_LABEL|$CERTBOT_SERVICE|$CERTBOT_PACKAGE|$CERTBOT_SVC_VAR|$CERTBOT_GROUP|$CERTBOT_ENTRY"

# --- Source actions ----------------------------------------------------------
source_service_actions "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
