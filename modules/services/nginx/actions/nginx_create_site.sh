#!/bin/bash
# =============================================================================
# modules/services/nginx/actions/nginx_create_site.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
#
# Variable namespace: _NGINX_CS_* (nginx create site)
# =============================================================================



# =============================================================================
# CONFIGURATION COLLECTION
# =============================================================================

_nginx_collect_domain() {
    prompt_required "Domain name (e.g. example.com)" _NGINX_CS_DOMAIN

    if [ -f "/etc/nginx/sites-available/$_NGINX_CS_DOMAIN" ]; then
        warn "Site '$_NGINX_CS_DOMAIN' already exists."
        confirm "Overwrite existing configuration?" || return 1
    fi

    echo ""
    echo "  www handling:"
    echo "    1)  Serve both www and non-www"
    echo "    2)  Redirect www to $_NGINX_CS_DOMAIN"
    echo "    3)  Redirect $_NGINX_CS_DOMAIN to www.$_NGINX_CS_DOMAIN"
    echo ""
    while true; do
        read -rp "  Selection [1]: " _NGINX_CS_WWW
        _NGINX_CS_WWW="${_NGINX_CS_WWW:-1}"
        case "$_NGINX_CS_WWW" in
            1|2|3) break ;;
            *) warn "Invalid selection — enter 1, 2, or 3." ;;
        esac
    done
}

_nginx_collect_network() {
    echo ""
	
    confirm "Listen on all IPv4 addresses?" \
        && _NGINX_CS_IPV4="0.0.0.0" \
        || prompt_required "IPv4 address to listen on" _NGINX_CS_IPV4

    if confirm "Listen on IPv6?"; then
        _NGINX_CS_IPV6=true
        confirm "Listen on all IPv6 addresses?" \
            && _NGINX_CS_IPV6_ADDR="::" \
            || prompt_required "IPv6 address to listen on" _NGINX_CS_IPV6_ADDR
    else
        _NGINX_CS_IPV6=false
        _NGINX_CS_IPV6_ADDR=""
    fi
}

_nginx_collect_general() {
    echo ""
    read -rp "  Client max body size [1m]: " _NGINX_CS_MAX_BODY
    _NGINX_CS_MAX_BODY="${_NGINX_CS_MAX_BODY:-1m}"
    confirm "Enable gzip compression?"  && _NGINX_CS_GZIP=true             || _NGINX_CS_GZIP=false
    confirm "Add security headers?"     && _NGINX_CS_SECURITY_HEADERS=true || _NGINX_CS_SECURITY_HEADERS=false
    confirm "Enable access logging?"    && _NGINX_CS_ACCESS_LOG=true       || _NGINX_CS_ACCESS_LOG=false
}

_nginx_collect_ssl() {
    echo ""
    if ! pkg_installed "certbot"; then
        warn "Certbot is not installed — SSL will not be available."
        _NGINX_CS_SSL=false
        _NGINX_CS_SSL_REDIRECT=false
        return 0
    fi

    if confirm "Set up SSL with Certbot?"; then
        _NGINX_CS_SSL=true
        warn "Note: If your app handles HTTPS redirection internally, enabling it here may cause redirect loops."
        confirm "Redirect HTTP to HTTPS?" && _NGINX_CS_SSL_REDIRECT=true || _NGINX_CS_SSL_REDIRECT=false
    else
        _NGINX_CS_SSL=false
        _NGINX_CS_SSL_REDIRECT=false
    fi
}

_nginx_collect_static() {
	section "Static Options"
	
    # Collection
    section "Domain";          _nginx_collect_domain   || { _nginx_cleanup; return 1; }
    section "Network";         _nginx_collect_network
    section "General Options"; _nginx_collect_general
	
    prompt_required "Document root (e.g. /var/www/$_NGINX_CS_DOMAIN)" _NGINX_CS_ROOT
    confirm "Enable static file caching?" && _NGINX_CS_STATIC_CACHE=true || _NGINX_CS_STATIC_CACHE=false
	
	section "SSL"
	_nginx_collect_ssl

    # Generation
    section "Generating Configuration"
    _NGINX_CS_CONFIG="/etc/nginx/sites-available/$_NGINX_CS_DOMAIN"
    

    if [ -n "$_NGINX_CS_ROOT" ] && [ ! -d "$_NGINX_CS_ROOT" ]; then
        mkdir -p "$_NGINX_CS_ROOT"
        info "Created document root: $_NGINX_CS_ROOT"
    fi
	
	_nginx_generate_static
	_nginx_preview_config

    _nginx_enable_site
    _nginx_request_ssl
    _nginx_cleanup
}

_nginx_collect_php() {
	section "PHP Options"
	
    # Collection
    section "Domain";          _nginx_collect_domain   || { _nginx_cleanup; return 1; }
    section "Network";         _nginx_collect_network
    section "General Options"; _nginx_collect_general
	
    prompt_required "Document root (e.g. /var/www/$_NGINX_CS_DOMAIN)" _NGINX_CS_ROOT
    echo ""
    echo "  PHP-FPM connection type:"
    echo "    1)  Unix socket (e.g. /run/php/php8.3-fpm.sock)"
    echo "    2)  TCP port    (e.g. 9000)"
    echo ""
    local _NGINX_CS_PHP_TYPE
    while true; do
        read -rp "  Selection [1]: " _NGINX_CS_PHP_TYPE
        _NGINX_CS_PHP_TYPE="${_NGINX_CS_PHP_TYPE:-1}"
        case "$_NGINX_CS_PHP_TYPE" in 1|2) break ;; *) warn "Invalid selection." ;; esac
    done
    if [ "$_NGINX_CS_PHP_TYPE" = "1" ]; then
        prompt_required "PHP-FPM socket path" _NGINX_CS_PHP_SOCKET
    else
        local _NGINX_CS_PHP_PORT
        prompt_required "PHP-FPM port" _NGINX_CS_PHP_PORT
        _NGINX_CS_PHP_SOCKET="127.0.0.1:$_NGINX_CS_PHP_PORT"
    fi
    confirm "Hide PHP version header?" && _NGINX_CS_PHP_HIDE_VERSION=true || _NGINX_CS_PHP_HIDE_VERSION=false
	
	section "SSL"
	_nginx_collect_ssl

    # Generation
    section "Generating Configuration"
    _NGINX_CS_CONFIG="/etc/nginx/sites-available/$_NGINX_CS_DOMAIN"
    

    if [ -n "$_NGINX_CS_ROOT" ] && [ ! -d "$_NGINX_CS_ROOT" ]; then
        mkdir -p "$_NGINX_CS_ROOT"
        info "Created document root: $_NGINX_CS_ROOT"
    fi
	
	_nginx_generate_php
	_nginx_preview_config

    _nginx_enable_site
    _nginx_request_ssl
    _nginx_cleanup
		    
}

_nginx_collect_proxy() {

	section "Reverse Proxy Options"
	
    # Collection
    section "Domain";          _nginx_collect_domain   || { _nginx_cleanup; return 1; }
    section "Network";         _nginx_collect_network
    section "General Options"; _nginx_collect_general
	
	
    read -rp "  Upstream host [127.0.0.1]: " _NGINX_CS_PROXY_HOST
    _NGINX_CS_PROXY_HOST="${_NGINX_CS_PROXY_HOST:-127.0.0.1}"
    prompt_required "Upstream port (e.g. 5000)" _NGINX_CS_PROXY_PORT
    confirm "Enable WebSocket support?" && _NGINX_CS_PROXY_WS=true || _NGINX_CS_PROXY_WS=false
    echo ""
    echo "  Proxy timeouts (hit enter to accept defaults):"
    read -rp "  Connect timeout [60s]: " _NGINX_CS_PROXY_CONNECT_TIMEOUT; _NGINX_CS_PROXY_CONNECT_TIMEOUT="${_NGINX_CS_PROXY_CONNECT_TIMEOUT:-60s}"
    read -rp "  Read timeout    [60s]: " _NGINX_CS_PROXY_READ_TIMEOUT;    _NGINX_CS_PROXY_READ_TIMEOUT="${_NGINX_CS_PROXY_READ_TIMEOUT:-60s}"
    read -rp "  Send timeout    [60s]: " _NGINX_CS_PROXY_SEND_TIMEOUT;    _NGINX_CS_PROXY_SEND_TIMEOUT="${_NGINX_CS_PROXY_SEND_TIMEOUT:-60s}"
	
	section "SSL"
	_nginx_collect_ssl

    # Generation
    section "Generating Configuration"
    _NGINX_CS_CONFIG="/etc/nginx/sites-available/$_NGINX_CS_DOMAIN"

	
	
	
	_nginx_generate_proxy
	_nginx_preview_config
    _nginx_enable_site
    _nginx_request_ssl
    _nginx_cleanup
}

_nginx_preview_config() {
    section "Configuration Preview"
    echo "$_NGINX_CS_CONFIG_CONTENT"
    echo ""
    confirm "Does this look correct?" || { _nginx_cleanup; return 1; }
    echo "$_NGINX_CS_CONFIG_CONTENT" > "$_NGINX_CS_CONFIG"
    info "Configuration written to: $_NGINX_CS_CONFIG"
}

# =============================================================================
# POST-GENERATION
# =============================================================================

_nginx_enable_site() {
    confirm "Enable site now?" || return 0
	
    ln -sf "$_NGINX_CS_CONFIG" "/etc/nginx/sites-enabled/$_NGINX_CS_DOMAIN"
	
    info "Site enabled."
	
    if ! nginx -t 2>/dev/null; then
        warn "Configuration has errors:"
        nginx -t 2>&1 | sed 's/^/    /'
        warn "Disabling site due to config errors."
        rm -f "/etc/nginx/sites-enabled/$_NGINX_CS_DOMAIN"
        return 1
    fi
	
    info "Configuration OK."
  
	if confirm "Reload Nginx?"; then
		if systemctl reload nginx; then
			info "Nginx reloaded."
		else
			warn "Failed to reload Nginx — check: journalctl -u nginx"
		fi
	fi
}

_nginx_request_ssl() {
    [ "$_NGINX_CS_SSL" = true ] || return 0
    section "SSL Certificate"
    info "Requesting SSL certificate for $_NGINX_CS_DOMAIN..."
    certbot --nginx -d "$_NGINX_CS_DOMAIN" -d "www.$_NGINX_CS_DOMAIN" || warn "Certbot failed — check output above."
}

_nginx_cleanup() {
    unset _NGINX_CS_DOMAIN _NGINX_CS_WWW _NGINX_CS_IPV4 _NGINX_CS_IPV6 _NGINX_CS_IPV6_ADDR
    unset _NGINX_CS_MAX_BODY _NGINX_CS_GZIP _NGINX_CS_SECURITY_HEADERS _NGINX_CS_ACCESS_LOG
    unset _NGINX_CS_SSL _NGINX_CS_SSL_REDIRECT _NGINX_CS_TYPE _NGINX_CS_ROOT _NGINX_CS_CONFIG
    unset _NGINX_CS_STATIC_CACHE _NGINX_CS_PHP_SOCKET _NGINX_CS_PHP_HIDE_VERSION
    unset _NGINX_CS_PHP_TYPE _NGINX_CS_PHP_PORT
    unset _NGINX_CS_PROXY_HOST _NGINX_CS_PROXY_PORT _NGINX_CS_PROXY_WS
    unset _NGINX_CS_PROXY_CONNECT_TIMEOUT _NGINX_CS_PROXY_READ_TIMEOUT _NGINX_CS_PROXY_SEND_TIMEOUT
}

# =============================================================================
# MAIN ACTION
# =============================================================================

action_nginx_create_site() {

    # Pre-checks
    if ! pkg_installed "nginx"; then
        warn "Nginx is not installed."
        return 1
    fi
    if ! systemctl is-active --quiet nginx; then
        warn "Nginx is not running."
        confirm "Continue anyway?" || return 1
    fi
    if ! nginx -t 2>/dev/null; then
        warn "Nginx configuration currently has errors:"
        nginx -t 2>&1 | sed 's/^/    /'
        confirm "Continue anyway?" || return 1
    fi

	section "Create Nginx Site"
	
	# Site Type Selection
	local -a _NGINX_CS_TYPE_OPTIONS=(
		"Static / HTML|_nginx_collect_static"
		"PHP|_nginx_collect_php"
		"Reverse Proxy (.NET, Node.js, Python, Ruby etc.)|_nginx_collect_proxy"
	)
	command_menu _NGINX_CS_TYPE_OPTIONS "Create Site"


}

# --- Register ----------------------------------------------------------------
register_action "Create Nginx Site|nginx_create_site|action_nginx_create_site"