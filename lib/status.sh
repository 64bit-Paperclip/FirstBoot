#!/bin/bash
# =============================================================================
# lib/status.sh — System Status Display
# Sourced by firstboot.sh after globals.sh
# Do not run directly
# Author:  Jason Penick
# GitHub:  https://github.com/64bit-Paperclip/FirstBoot
# =============================================================================

# --- Helper: colorize a status string ----------------------------------------
colorize_status() {
    case "$1" in
        "running")       echo -e "${GREEN}running${NC}" ;;
        "stopped")       echo -e "${YELLOW}stopped${NC}" ;;
        "not installed") echo -e "${RED}not installed${NC}" ;;
        "installed")     echo -e "${GREEN}installed${NC}" ;;
        *)               echo "$1" ;;
    esac
}

# --- show_status -------------------------------------------------------------
# Refreshes all detection data then displays system info and service statuses
show_status() {
    detect_system
    detect_session
	detect_services

    section "System Status"

    echo -e "  ${BOLD}Hostname:${NC}  $SYS_HOSTNAME"
    echo -e "  ${BOLD}OS:${NC}        $SYS_OS"
    echo -e "  ${BOLD}IPv4:${NC}      $SYS_IPV4"
    echo -e "  ${BOLD}IPv6:${NC}      $SYS_IPV6"
    echo -e "  ${BOLD}Uptime:${NC}    $SYS_UPTIME"
    echo -e "  ${BOLD}RAM:${NC}       $SYS_RAM_TOTAL total, $SYS_RAM_FREE free"
    echo -e "  ${BOLD}Disk:${NC}      $SYS_DISK_TOTAL total, $SYS_DISK_FREE free"
    echo -e "  ${BOLD}Load:${NC}      $SYS_LOAD"
    echo -e "  ${BOLD}CPUs:${NC}      $SYS_CPU_CORES"
	echo ""
	echo -e "  ${BOLD}USER IP:${NC}   $CURRENT_IP"
    echo ""
    echo -e "  ${BOLD}Services:${NC}"
    echo ""

    # Build display arrays from SERVICES and SVC_* variables
    local -a DISP_LABELS=()
    local -a DISP_STATUSES=()

    for entry in "${SERVICES[@]}"; do
        IFS='|' read -r label svc pkg svcvar groups entry_fn <<< "$entry"
        status="${!svcvar:-not installed}"
        DISP_LABELS+=("$label")
        DISP_STATUSES+=("$status")
    done

    # 2 column display
    COLS=2
    COUNT=${#DISP_LABELS[@]}
    ROWS=$(( (COUNT + COLS - 1) / COLS ))

    for (( row=0; row<ROWS; row++ )); do
        printf "  "
        for (( col=0; col<COLS; col++ )); do
            idx=$(( row + col * ROWS ))
            if [ $idx -lt $COUNT ]; then
                label="${DISP_LABELS[$idx]}:"
                status="${DISP_STATUSES[$idx]}"
                colored=$(colorize_status "$status")
                printf "%-14s %-27s" "$label" "$colored"
            fi
        done
        echo ""
    done

	section_break
}

export -f show_status