#!/bin/bash
# =============================================================================
# modules/services/nginx/actions/nginx_install.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Action ------------------------------------------------------------------
action_nginx_install() {
    

    if pkg_installed "nginx"; then
        warn "Nginx is already installed."
        return 1
    fi

	section "Installing Nginx"

    info "Updating package list..."
    apt update -qq || { error "Failed to update package list."; return 1; }

    info "Installing Nginx..."
    apt install -y nginx || { error "Failed to install Nginx."; return 1; }

    info "Nginx installed."
}

# --- Register ----------------------------------------------------------------
register_action "Install Nginx|nginx_install|action_nginx_install"