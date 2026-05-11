#!/bin/bash
# =============================================================================
# modules/services/nginx/lib/nginx_blocks.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
#
# Purpose:
#   Provides reusable nginx configuration block functions for use across
#   nginx action scripts. Each _nginx_block_* function outputs a snippet
#   of valid nginx config text. Generator functions (_nginx_generate_*)
#   compose these blocks in the correct order and write the final config
#   to disk.
#
# Usage:
#   Sourced automatically by nginx.sh at startup. Do not source directly
#   from action scripts -- rely on nginx.sh having sourced it first.
#
# Naming conventions:
#   _nginx_block_*     -- outputs a single nginx config block
#   _nginx_generate_*  -- composes blocks into a complete site config
#
# Variable namespace:
#   All variables used by these functions are expected to follow the
#   _NGINX_CS_* prefix convention defined in nginx_create_site.sh
# =============================================================================

_nginx_block_open()   { echo "server {"; }
_nginx_block_close()  { echo "}"; echo ""; }

_nginx_block_listen() {
    local _port="$1"
    echo "    listen ${_NGINX_CS_IPV4}:${_port};"
    [ "$_NGINX_CS_IPV6" = true ] && echo "    listen [${_NGINX_CS_IPV6_ADDR}]:${_port};"
}

_nginx_block_server_name() {
    case "$_NGINX_CS_WWW" in
        1) echo "    server_name ${_NGINX_CS_DOMAIN} www.${_NGINX_CS_DOMAIN};" ;;
        2) echo "    server_name www.${_NGINX_CS_DOMAIN};" ;;
        3) echo "    server_name ${_NGINX_CS_DOMAIN};" ;;
    esac
}

_nginx_block_max_body() {
    echo "    client_max_body_size ${_NGINX_CS_MAX_BODY};"
}

_nginx_block_gzip() {
    [ "$_NGINX_CS_GZIP" = true ] || return 0
    echo ""
    echo "    # Gzip compression"
    echo "    gzip on;"
    echo "    gzip_vary on;"
    echo "    gzip_proxied any;"
    echo "    gzip_comp_level 6;"
    echo "    gzip_types text/plain text/css text/xml application/json application/javascript application/xml+rss application/atom+xml image/svg+xml;"
}

_nginx_block_security_headers() {
    [ "$_NGINX_CS_SECURITY_HEADERS" = true ] || return 0
    echo ""
    echo "    # Security headers"
    echo "    add_header X-Frame-Options \"SAMEORIGIN\" always;"
    echo "    add_header X-Content-Type-Options \"nosniff\" always;"
    echo "    add_header X-XSS-Protection \"1; mode=block\" always;"
    echo "    add_header Referrer-Policy \"strict-origin-when-cross-origin\" always;"
    echo "    add_header Content-Security-Policy \"default-src 'self'\" always;"
}

_nginx_block_logging() {
    echo ""
    if [ "$_NGINX_CS_ACCESS_LOG" = true ]; then
        echo "    access_log /var/log/nginx/${_NGINX_CS_DOMAIN}_access.log;"
    else
        echo "    access_log off;"
    fi
    echo "    error_log  /var/log/nginx/${_NGINX_CS_DOMAIN}_error.log;"
}

_nginx_block_ssl_redirect() {
    [ "$_NGINX_CS_SSL_REDIRECT" = true ] || return 0
    echo ""
    echo "    # HTTP to HTTPS redirect"
    echo "    if (\$scheme != \"https\") {"
    echo "        return 301 https://\$host\$request_uri;"
    echo "    }"
}

_nginx_block_www_redirect() {
    [ "$_NGINX_CS_WWW" = "1" ] && return 0
    local _from="" _to=""
    case "$_NGINX_CS_WWW" in
        2) _from="www.${_NGINX_CS_DOMAIN}"; _to="${_NGINX_CS_DOMAIN}" ;;
        3) _from="${_NGINX_CS_DOMAIN}";     _to="www.${_NGINX_CS_DOMAIN}" ;;
    esac
    echo ""
    _nginx_block_open
    _nginx_block_listen 80
    echo "    server_name ${_from};"
    echo "    return 301 \$scheme://${_to}\$request_uri;"
    _nginx_block_close
}

# --- Static blocks -----------------------------------------------------------
_nginx_block_root_static() {
    echo "    root ${_NGINX_CS_ROOT};"
    echo "    index index.html index.htm;"
}

_nginx_block_location_static() {
    echo ""
    echo "    location / {"
    echo "        try_files \$uri \$uri/ =404;"
    echo "    }"
}

_nginx_block_static_cache() {
    [ "$_NGINX_CS_STATIC_CACHE" = true ] || return 0
    echo ""
    echo "    # Static file caching"
    echo "    location ~* \.(jpg|jpeg|png|gif|ico|css|js|woff|woff2|ttf|svg)\$ {"
    echo "        expires 30d;"
    echo "        add_header Cache-Control \"public, no-transform\";"
    echo "    }"
}

# --- PHP blocks --------------------------------------------------------------
_nginx_block_root_php() {
    echo "    root ${_NGINX_CS_ROOT};"
    echo "    index index.php index.html;"
}

_nginx_block_location_php() {
    echo ""
    echo "    location / {"
    echo "        try_files \$uri \$uri/ /index.php?\$query_string;"
    echo "    }"
    echo ""
    echo "    location ~ \.php\$ {"
    echo "        fastcgi_pass ${_NGINX_CS_PHP_SOCKET};"
    echo "        fastcgi_index index.php;"
    echo "        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;"
    echo "        include fastcgi_params;"
    [ "$_NGINX_CS_PHP_HIDE_VERSION" = true ] && echo "        fastcgi_hide_header X-Powered-By;"
    echo "    }"
    echo ""
    echo "    location ~ /\.ht {"
    echo "        deny all;"
    echo "    }"
}

# --- Proxy blocks ------------------------------------------------------------
_nginx_block_location_proxy() {
    echo ""
    echo "    location / {"
    echo "        proxy_pass http://${_NGINX_CS_PROXY_HOST}:${_NGINX_CS_PROXY_PORT};"
    echo "        proxy_set_header Host \$host;"
    echo "        proxy_set_header X-Real-IP \$remote_addr;"
    echo "        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;"
    echo "        proxy_set_header X-Forwarded-Proto \$scheme;"
    echo ""
    echo "        proxy_connect_timeout ${_NGINX_CS_PROXY_CONNECT_TIMEOUT};"
    echo "        proxy_read_timeout    ${_NGINX_CS_PROXY_READ_TIMEOUT};"
    echo "        proxy_send_timeout    ${_NGINX_CS_PROXY_SEND_TIMEOUT};"
    if [ "$_NGINX_CS_PROXY_WS" = true ]; then
        echo ""
        echo "        # WebSocket support"
        echo "        proxy_http_version 1.1;"
        echo "        proxy_set_header Upgrade \$http_upgrade;"
        echo "        proxy_set_header Connection \"upgrade\";"
    fi
    echo "    }"
}



# =============================================================================
# CONFIG GENERATORS
# =============================================================================
_nginx_generate_static() {
    _NGINX_CS_CONFIG_CONTENT=$(
        _nginx_block_open
        _nginx_block_listen 80
        _nginx_block_server_name
        echo ""
        _nginx_block_root_static
        echo ""
        _nginx_block_max_body
        _nginx_block_gzip
        _nginx_block_security_headers
        _nginx_block_ssl_redirect
        _nginx_block_location_static
        _nginx_block_static_cache
        _nginx_block_logging
        _nginx_block_close
        _nginx_block_www_redirect
    )
}

_nginx_generate_php() {
    _NGINX_CS_CONFIG_CONTENT=$(
        _nginx_block_open
        _nginx_block_listen 80
        _nginx_block_server_name
        echo ""
        _nginx_block_root_php
        echo ""
        _nginx_block_max_body
        _nginx_block_gzip
        _nginx_block_security_headers
        _nginx_block_ssl_redirect
        _nginx_block_location_php
        _nginx_block_logging
        _nginx_block_close
        _nginx_block_www_redirect
    )
}

_nginx_generate_proxy() {
    _NGINX_CS_CONFIG_CONTENT=$(
        _nginx_block_open
        _nginx_block_listen 80
        _nginx_block_server_name
        echo ""
        _nginx_block_max_body
        _nginx_block_gzip
        _nginx_block_security_headers
        _nginx_block_ssl_redirect
        _nginx_block_location_proxy
        _nginx_block_logging
        _nginx_block_close
        _nginx_block_www_redirect
    )
}