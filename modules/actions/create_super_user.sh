#!/bin/bash
# =============================================================================
# modules/actions/create_superuser.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Internal: create new user with sudo -------------------------------------
_csu_create_new_user() {
    section "Create New Sudo User"

    # --- Username ------------------------------------------------------------
    local _csu_user
    while true; do
        read -rp "  Username: " _csu_user
        if [ -z "$_csu_user" ]; then
            warn "Username cannot be empty."
        elif [[ ! "$_csu_user" =~ ^[a-zA-Z0-9_-]+$ ]]; then
            warn "Username can only contain letters, numbers, underscores and hyphens."
        elif id "$_csu_user" &>/dev/null; then
            warn "User '$_csu_user' already exists."
        else
            break
        fi
    done

    # --- Create user ---------------------------------------------------------
    adduser --gecos "" "$_csu_user" || { error "Failed to create user '$_csu_user'."; return 1; }
    usermod -aG sudo "$_csu_user" || { error "Failed to grant sudo to '$_csu_user'."; return 1; }

    info "User '$_csu_user' created with sudo access."
}

# --- Internal: grant sudo to existing user -----------------------------------
_csu_grant_existing_user() {
    section "Grant Sudo to Existing User"

    # --- Get non-root, non-sudo users ----------------------------------------
    local -a _csu_users=()
    while IFS= read -r _csu_line; do
        local _csu_u
        _csu_u=$(echo "$_csu_line" | cut -d: -f1)
        # Skip system users (UID < 1000), root, and users already in sudo
        local _csu_uid
        _csu_uid=$(id -u "$_csu_u" 2>/dev/null)
        [ "$_csu_uid" -lt 1000 ] && continue
        groups "$_csu_u" 2>/dev/null | grep -qw "sudo" && continue
        _csu_users+=("$_csu_u")
    done < /etc/passwd

    if [ ${#_csu_users[@]} -eq 0 ]; then
        warn "No eligible users found."
        return 1
    fi

    # --- Display users -------------------------------------------------------
    echo ""
    local _csu_idx=1
    for _csu_u in "${_csu_users[@]}"; do
        printf "    %d)  %s\n" "$_csu_idx" "$_csu_u"
        (( _csu_idx++ ))
    done
    echo ""

    # --- Select user ---------------------------------------------------------
    local _csu_choice
    while true; do
        read -rp "  Select user: " _csu_choice
        if [[ "$_csu_choice" =~ ^[0-9]+$ ]] && \
           [ "$_csu_choice" -ge 1 ] && \
           [ "$_csu_choice" -le "${#_csu_users[@]}" ]; then
            break
        fi
        warn "Invalid selection."
    done

    local _csu_selected="${_csu_users[$(( _csu_choice - 1 ))]}"

    # --- Confirm and grant ---------------------------------------------------
    echo ""
    warn "This will grant sudo access to '$_csu_selected'."
    echo ""
    confirm_prompt "Are you sure?" || return 1

    usermod -aG sudo "$_csu_selected" || { error "Failed to grant sudo to '$_csu_selected'."; return 1; }
    info "Sudo access granted to '$_csu_selected'."
}

# --- Action ------------------------------------------------------------------
action_create_superuser() {
    section "Create Super User"

    if ! is_user_root; then
        warn "This action requires root privileges."
        return 1
    fi

    echo ""
    echo "  What would you like to do?"
    echo ""
    echo "    1)  Create a new user with sudo access"
    echo "    2)  Grant sudo access to an existing user"
    echo ""

    local _csu_mode
    while true; do
        read -rp "  Selection: " _csu_mode
        case "$_csu_mode" in
            1) _csu_create_new_user  ; break ;;
            2) _csu_grant_existing_user ; break ;;
            *) warn "Invalid selection -- enter 1 or 2." ;;
        esac
    done
}

# --- Register ----------------------------------------------------------------
register_action "Create Super User|create_superuser|action_create_superuser"