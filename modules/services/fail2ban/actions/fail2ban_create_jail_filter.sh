#!/bin/bash
# =============================================================================
# modules/services/fail2ban/actions/fail2ban_create_jail_builtin.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Action ------------------------------------------------------------------
action_fail2ban_create_jail_filter() {
    section "Create Jail from Built-in Filter"

    if ! is_fail2ban_installed; then
        warn "Fail2ban is not installed."
        return 1
    fi

    if [ ! -d /etc/fail2ban/filter.d ]; then
        warn "No built-in filters found."
        return 1
    fi

    # Get existing jail names so we can exclude them
    local -a _f2b_cjb_existing=()
    fail2ban_get_jail_names _f2b_cjb_existing

    # Build list of available filters that don't already have a jail
    local -a _f2b_cjb_available=()
    local _f2b_cjb_filter_file _f2b_cjb_filter_name _f2b_cjb_exists _f2b_cjb_existing_name
    for _f2b_cjb_filter_file in /etc/fail2ban/filter.d/*.conf; do
        _f2b_cjb_filter_name=$(basename "$_f2b_cjb_filter_file" .conf)
        _f2b_cjb_exists=false
        for _f2b_cjb_existing_name in "${_f2b_cjb_existing[@]}"; do
            [ "$_f2b_cjb_existing_name" = "$_f2b_cjb_filter_name" ] && _f2b_cjb_exists=true && break
        done
        [ "$_f2b_cjb_exists" = true ] && continue
        _f2b_cjb_available+=("$_f2b_cjb_filter_name")
    done

    if [ ${#_f2b_cjb_available[@]} -eq 0 ]; then
        info "All available filters already have jails configured."
        return 0
    fi

    _fail2ban_select_jail _f2b_cjb_available "Select filter" || return 1
    local _f2b_cjb_selected="$_FAIL2BAN_SELECTED_JAIL"
    unset _FAIL2BAN_SELECTED_JAIL

    # Collect jail configuration
    sub_section "Configure Jail: $_f2b_cjb_selected"

    local _f2b_cjb_maxretry _f2b_cjb_bantime _f2b_cjb_findtime
    _fail2ban_collect_maxretry _f2b_cjb_maxretry
    _fail2ban_collect_bantime  _f2b_cjb_bantime
    _fail2ban_collect_findtime _f2b_cjb_findtime

    # Build jail config
    local _f2b_cjb_content
    _f2b_cjb_content="[${_f2b_cjb_selected}]
enabled  = true
maxretry = ${_f2b_cjb_maxretry}
bantime  = ${_f2b_cjb_bantime}
findtime = ${_f2b_cjb_findtime}"

    # Preview
    echo ""
    echo -e "  ${BOLD}Configuration Preview:${NC}"
    echo ""
    echo "$_f2b_cjb_content" | sed 's/^/    /'
    echo ""

    confirm_prompt "Write this jail configuration?" || return 1

    local _f2b_cjb_jail_file
    _f2b_cjb_jail_file=$(fail2ban_get_jail_file "$_f2b_cjb_selected")
    echo "$_f2b_cjb_content" > "$_f2b_cjb_jail_file"
    info "Jail '$_f2b_cjb_selected' created at: $_f2b_cjb_jail_file"

if is_fail2ban_running; then
    fail2ban-client reload 2>/dev/null && \
    fail2ban-client reload "$_f2b_cjb_selected" 2>/dev/null && \
        info "Jail loaded."
fi
}

# --- Register ----------------------------------------------------------------
register_action "Create Jail from Built-in Filter|fail2ban_create_jail_builtin|action_fail2ban_create_jail_filter"