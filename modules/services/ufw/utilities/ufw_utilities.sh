
#!/bin/bash
# =============================================================================
# modules/services/ufw/utilities/ufw_utilities.sh
# Sourced by ufw.sh at startup
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Utility: get all configured rules ---------------------------------------
# Uses 'ufw show added' so works whether UFW is active or not
# Outputs rules to stdout
ufw_get_rules() {
    ufw show added 2>/dev/null | grep "^ufw" | sed 's/^ufw //'
}