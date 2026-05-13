#!/bin/bash
# =============================================================================
# lib/ui.sh — User Interface Functions
# Sourced by firstboot.sh after globals.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
#
# UI Suppression:
#   Set NO_SECTION_UI=true before calling section() or section_break()
#   to suppress output. Unset after to restore normal behavior.
#   Example:
#     NO_SECTION_UI=true
#     section "My Title"   # suppressed
#     unset NO_SECTION_UI
# =============================================================================


section() {

	[ "${NO_SECTION_UI:-false}" = "true" ] && return 0

    local title="$1"
    local title_len=${#title}
    local total=80
    local prefix="╔══[ "
    local suffix_len=$(( total - ${#prefix} - title_len - 3 ))
    local suffix=$(printf '%0.s═' $(seq 1 $suffix_len))

    
    echo -e "${CYAN}${prefix}${NC}${BOLD}${title}${CYAN} ]${suffix}${NC}"
    echo ""
}



section_break() {

	[ "${NO_SECTION_UI:-false}" = "true" ] && return 0

	echo ""
	echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════════════${NC}"
	echo ""
}

section_end() {

	[ "${NO_SECTION_UI:-false}" = "true" ] && return 0

    local title="End $1"
    local title_len=${#title}
    local total=80
    local prefix="╚══[ "
    local suffix_len=$(( total - ${#prefix} - title_len - 3 ))
    local suffix=$(printf '%0.s═' $(seq 1 $suffix_len))
    echo ""
    echo -e "${CYAN}${prefix}${NC}${BOLD}${title}${CYAN} ]${suffix}${NC}"
    
    
}

sub_section() {

	[ "${NO_SECTION_UI:-false}" = "true" ] && return 0

    local title="$1"
    local title_len=${#title}
    local total=80
    local prefix="   [ "
    local suffix_len=$(( total - ${#prefix} - title_len - 3 ))
    local suffix=$(printf '%0.s═' $(seq 1 $suffix_len))

    
    echo -e "${CYAN}${prefix}${NC}${BOLD}${title}${CYAN} ]${suffix}${NC}"
    echo ""
}

draw_banner() {
	echo ""
	echo -e "${CYAN}"
	echo -e "╔══════════════════════════════════════════════════════════════════════════════╗"
	echo -e "║ ${NC}FIRSTBOOT v1.0${CYAN}                                   ${NC}Server Management Toolkit${CYAN} ║"
	echo -e "╠══════════════════════════════════════════════════════════════════════════════╣"
	echo -e "║                                                                              ║"
	echo -e "╚══════════════════════════════════════════════════════════════════════════════╝"
	echo -e "${NC}"
}


wait_for_any_key(){
    read -rp "  [ Press any key to continue ]" -n1
    echo -e "\r\033[2K"
}


confirm_prompt() {
    local prompt="${1:-Are you sure?}"
    local answer
    while true; do
        echo -en "  $prompt (yes/no): "
        read -r answer
        case "$answer" in
            yes|y) return 0 ;;
            no|n)  return 1 ;;
            *)     warn "Please enter yes/no or y/n." ;;
        esac
    done
}

required_prompt() {
    local prompt="$1"
    local varname="$2"
    local value
    while true; do
        read -rp "  $prompt: " value
        [ -n "$value" ] && break
        warn "This field cannot be empty."
    done
    printf -v "$varname" '%s' "$value"
}

dynamic_command_menu() {
    local _generate_fn="$1"
    local _title="$2"

    while true; do
        local -a _dynamic_options=()
        "$_generate_fn" _dynamic_options

        section "$_title"
        local i=1
        local -a _index_map=()
        local _idx=0
        for entry in "${_dynamic_options[@]}"; do
            IFS='|' read -r label fn <<< "$entry"
            if [ "$label" = "---" ]; then
                if [ -n "$fn" ]; then
                    echo -e " ${CYAN}-[ ${BOLD}$fn ${CYAN}]-${NC}"
                else
                    echo ""
                fi
            else
                printf "    %d)  %s\n" "$i" "$label"
                _index_map+=("$_idx")
                (( i++ ))
            fi
            (( _idx++ ))
        done
        echo ""
        echo "    0)  Back"
        echo ""
        read -rp "  Selection: " CMD_CHOICE

        # -- Go Back --
        if [ "$CMD_CHOICE" = "0" ] || [[ "${CMD_CHOICE,,}" == "back" ]]; then
            section_end "$_title"
            break
        fi

        local _real_idx=""

        if [[ "$CMD_CHOICE" =~ ^[0-9]+$ ]]; then
            local _map_idx=$(( CMD_CHOICE - 1 ))
            if [ "$_map_idx" -lt 0 ] || [ "$_map_idx" -ge "${#_index_map[@]}" ]; then
                warn "Invalid selection."
                section_end "$_title"
                continue
            fi
            _real_idx="${_index_map[$_map_idx]}"
        else
            for _mapped in "${_index_map[@]}"; do
                IFS='|' read -r _lbl _fn <<< "${_dynamic_options[$_mapped]}"
                if [[ "${_lbl,,}" == "${CMD_CHOICE,,}" ]]; then
                    _real_idx="$_mapped"
                    break
                fi
            done
            if [ -z "$_real_idx" ]; then
                warn "Invalid selection."
                section_end "$_title"
                continue
            fi
        fi

        IFS='|' read -r label fn <<< "${_dynamic_options[$_real_idx]}"
        if declare -f "$fn" > /dev/null 2>&1; then
            section_end "$_title"
            "$fn"
        else
            warn "Function '$fn' not found."
            section_end "$_title"
        fi
    done
    unset CMD_CHOICE
}

command_menu() {
    local -n _options="$1"
    local _title="$2"
    while true; do
        section "$_title"
        local i=1
        local -a _index_map=()
        local _idx=0
        for entry in "${_options[@]}"; do
            IFS='|' read -r label fn <<< "$entry"
            if [ "$label" = "---" ]; then
                if [ -n "$fn" ]; then
                    echo -e " ${CYAN}-[ ${NC}${BOLD}$fn ${NC}${CYAN}]-${NC}"
                else
                    echo ""
                fi
            else
                printf "    %d)  %s\n" "$i" "$label"
                _index_map+=("$_idx")
                (( i++ ))
            fi
            (( _idx++ ))
        done
        echo ""
        echo "    0)  Back"
        echo ""
        read -rp "  Selection: " CMD_CHOICE
        
        # -- Go Back --
        if [ "$CMD_CHOICE" = "0" ] || [[ "${CMD_CHOICE,,}" == "back" ]]; then
            section_end "$_title"
            break
        fi

        local _real_idx=""

        if [[ "$CMD_CHOICE" =~ ^[0-9]+$ ]]; then
            local _map_idx=$(( CMD_CHOICE - 1 ))
            if [ "$_map_idx" -lt 0 ] || [ "$_map_idx" -ge "${#_index_map[@]}" ]; then
                warn "Invalid selection."
                section_end "$_title"
                continue
            fi
            _real_idx="${_index_map[$_map_idx]}"
        else
            for _mapped in "${_index_map[@]}"; do
                IFS='|' read -r _lbl _fn <<< "${_options[$_mapped]}"
                if [[ "${_lbl,,}" == "${CMD_CHOICE,,}" ]]; then
                    _real_idx="$_mapped"
                    break
                fi
            done
            if [ -z "$_real_idx" ]; then
                warn "Invalid selection."
                section_end "$_title"
                continue
            fi
        fi

        IFS='|' read -r label fn <<< "${_options[$_real_idx]}"
        if declare -f "$fn" > /dev/null 2>&1; then
            section_end "$_title"
            "$fn"
        else
            warn "Function '$fn' not found."
            section_end "$_title"
        fi
    done
    unset CMD_CHOICE
}

export -f section

