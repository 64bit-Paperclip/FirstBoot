#!/bin/bash
# =============================================================================
# modules/services/spamassassin/spamassassin.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Service variables -------------------------------------------------------
SPAMASSASSIN_LABEL="SpamAssassin"
SPAMASSASSIN_SERVICE="spamassassin"
SPAMASSASSIN_PACKAGE="spamassassin"
SPAMASSASSIN_SVC_VAR="SVC_SPAMASSASSIN"
SPAMASSASSIN_GROUP="mail"
SPAMASSASSIN_ENTRY="spamassassin_entry"

# --- Initialize status variable ----------------------------------------------
SVC_SPAMASSASSIN="not installed"

# --- Directory variables -----------------------------------------------------
SPAMASSASSIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPAMASSASSIN_ACTIONS_DIR="$SPAMASSASSIN_DIR/actions"

# --- Global Utility Functions ------------------------------------------------
is_spamassassin_installed() {
    pkg_installed "$SPAMASSASSIN_PACKAGE"
}

is_spamassassin_running() {
    svc_running "$SPAMASSASSIN_SERVICE"
}

# --- Entry function ----------------------------------------------------------
spamassassin_entry() {
    echo "SpamAssassin control not yet complete"
}

# --- Register ----------------------------------------------------------------
register_service "$SPAMASSASSIN_LABEL|$SPAMASSASSIN_SERVICE|$SPAMASSASSIN_PACKAGE|$SPAMASSASSIN_SVC_VAR|$SPAMASSASSIN_GROUP|$SPAMASSASSIN_ENTRY"

# --- Source actions ----------------------------------------------------------
source_service_actions "$SPAMASSASSIN_DIR"