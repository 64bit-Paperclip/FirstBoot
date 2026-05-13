#!/bin/bash
# =============================================================================
# modules/services/mysql/actions/mysql_delete_user.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================


# --- Drop specific user@host -------------------------------------------------
_mysql_du_by_user_host() {
    section "Drop Specific User@Host"
 
    local -a _mysql_du_pairs=()
    while IFS=$'\t' read -r _mysql_du_u _mysql_du_h; do
        _mysql_du_pairs+=("${_mysql_du_u}@${_mysql_du_h}")
    done <<< "$(_mysql_du_get_users)"
 
    if [ ${#_mysql_du_pairs[@]} -eq 0 ]; then
        warn "No users found."
        return 1
    fi
 
    echo ""
    local _mysql_du_idx=1
    for _mysql_du_pair in "${_mysql_du_pairs[@]}"; do
        printf "    %d)  %s\n" "$_mysql_du_idx" "$_mysql_du_pair"
        (( _mysql_du_idx++ ))
    done
    echo ""
 
    local _mysql_du_choice
    while true; do
        read -rp "  Select user to drop: " _mysql_du_choice
        if [[ "$_mysql_du_choice" =~ ^[0-9]+$ ]] && \
           [ "$_mysql_du_choice" -ge 1 ] && \
           [ "$_mysql_du_choice" -le "${#_mysql_du_pairs[@]}" ]; then
            break
        fi
        warn "Invalid selection."
    done
 
    local _mysql_du_selected="${_mysql_du_pairs[$(( _mysql_du_choice - 1 ))]}"
    local _mysql_du_user="${_mysql_du_selected%@*}"
    local _mysql_du_host="${_mysql_du_selected#*@}"
 
    echo ""
    warn "This will drop the following user:"
    echo "    '${_mysql_du_user}'@'${_mysql_du_host}'"
    echo ""
 
    confirm_prompt "Are you sure?" || return 1
 
    mysql_drop_user "$_mysql_du_user" "$_mysql_du_host"
    mysql -u root -se "FLUSH PRIVILEGES;" 2>/dev/null
}
 
# --- Drop all hosts for a username -------------------------------------------
_mysql_du_by_username() {

    section "Drop All Users By Username"
 
    local -a _mysql_du_names=()
    while IFS=$'\t' read -r _mysql_du_u _mysql_du_h; do
        local _mysql_du_found=false
        for _mysql_du_existing in "${_mysql_du_names[@]}"; do
            [ "$_mysql_du_existing" = "$_mysql_du_u" ] && _mysql_du_found=true && break
        done
        [ "$_mysql_du_found" = false ] && _mysql_du_names+=("$_mysql_du_u")
    done <<< "$(_mysql_du_get_users)"
 
    if [ ${#_mysql_du_names[@]} -eq 0 ]; then
        warn "No users found."
        return 1
    fi
 
    echo ""
    local _mysql_du_idx=1
    for _mysql_du_name in "${_mysql_du_names[@]}"; do
        printf "    %d)  %s\n" "$_mysql_du_idx" "$_mysql_du_name"
        (( _mysql_du_idx++ ))
    done
    echo ""
 
    local _mysql_du_choice
    while true; do
        read -rp "  Select username: " _mysql_du_choice
        if [[ "$_mysql_du_choice" =~ ^[0-9]+$ ]] && \
           [ "$_mysql_du_choice" -ge 1 ] && \
           [ "$_mysql_du_choice" -le "${#_mysql_du_names[@]}" ]; then
            break
        fi
        warn "Invalid selection."
    done
 
    local _mysql_du_selected="${_mysql_du_names[$(( _mysql_du_choice - 1 ))]}"
 
    # Show what will be dropped
    echo ""
    warn "This will drop the following entries:"
    while IFS=$'\t' read -r _mysql_du_u _mysql_du_h; do
        [ "$_mysql_du_u" = "$_mysql_du_selected" ] && echo "    '${_mysql_du_u}'@'${_mysql_du_h}'"
    done <<< "$(_mysql_du_get_users)"
    echo ""
 
    confirm_prompt "Are you sure?" || return 1
 
    mysql_drop_all_users_with_username "$_mysql_du_selected"
}
 
# --- Drop all users for a host -----------------------------------------------
_mysql_du_by_host() {
    section "Drop All Users for a Host"
 
    local -a _mysql_du_hosts=()
    while IFS=$'\t' read -r _mysql_du_u _mysql_du_h; do
        local _mysql_du_found=false
        for _mysql_du_existing in "${_mysql_du_hosts[@]}"; do
            [ "$_mysql_du_existing" = "$_mysql_du_h" ] && _mysql_du_found=true && break
        done
        [ "$_mysql_du_found" = false ] && _mysql_du_hosts+=("$_mysql_du_h")
    done <<< "$(_mysql_du_get_users)"
 
    if [ ${#_mysql_du_hosts[@]} -eq 0 ]; then
        warn "No hosts found."
        return 1
    fi
 
    echo ""
    local _mysql_du_idx=1
    for _mysql_du_host in "${_mysql_du_hosts[@]}"; do
        printf "    %d)  %s\n" "$_mysql_du_idx" "$_mysql_du_host"
        (( _mysql_du_idx++ ))
    done
    echo ""
 
    local _mysql_du_choice
    while true; do
        read -rp "  Select host: " _mysql_du_choice
        if [[ "$_mysql_du_choice" =~ ^[0-9]+$ ]] && \
           [ "$_mysql_du_choice" -ge 1 ] && \
           [ "$_mysql_du_choice" -le "${#_mysql_du_hosts[@]}" ]; then
            break
        fi
        warn "Invalid selection."
    done
 
    local _mysql_du_selected="${_mysql_du_hosts[$(( _mysql_du_choice - 1 ))]}"
 
    # Show what will be dropped
    echo ""
    warn "This will drop the following entries:"
    while IFS=$'\t' read -r _mysql_du_u _mysql_du_h; do
        [ "$_mysql_du_h" = "$_mysql_du_selected" ] && echo "    '${_mysql_du_u}'@'${_mysql_du_h}'"
    done <<< "$(_mysql_du_get_users)"
    echo ""
 
    confirm_prompt "Are you sure?" || return 1
 
    mysql_du_drop_all_users_with_host "$_mysql_du_selected"
}
 
# =============================================================================
# MAIN ACTION
# =============================================================================
 
action_mysql_delete_user() {
    section "Delete MySQL User"
 
    if ! is_mysql_installed; then
        warn "MySQL is not installed."
        return 1
    fi
 
    if ! is_mysql_running; then
        warn "MySQL is not running."
        return 1
    fi
 
    echo ""
    echo "  What would you like to delete?"
    echo ""
    echo "    1)  Specific user@host"
    echo "    2)  All hosts for a username"
    echo "    3)  All users for a host"
    echo ""
 
    local _mysql_du_mode
    while true; do
        read -rp "  Selection: " _mysql_du_mode
        case "$_mysql_du_mode" in
            1) _mysql_du_by_user_host ; break ;;
            2) _mysql_du_by_username  ; break ;;
            3) _mysql_du_by_host      ; break ;;
            *) warn "Invalid selection -- enter 1, 2, or 3." ;;
        esac
    done
}
 
# --- Register ----------------------------------------------------------------
register_action "Delete MySQL User|mysql_delete_user|action_mysql_delete_user"
 