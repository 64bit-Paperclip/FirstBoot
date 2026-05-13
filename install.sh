#!/bin/bash

INSTALL_DIR="/opt/firstboot"
FIRSTBOOT_RUN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"


run_firstboot_install(){


    # Must be run as super user
    if [ "$EUID" -ne 0 ]; then
        echo "Error: install.sh must be run as super user."
        echo ""
        echo "  Try: sudo bash install.sh"
        echo ""
        exit 1
    fi

    # Already installed in the right place
    if [ "$FIRSTBOOT_RUN_DIR" = "$INSTALL_DIR" ]; then
        echo "FirstBoot is already installed."
        echo ""
        echo "  To run:     firstboot"
        echo "  To update:  firstboot (use the Update option in the menu)"
        echo ""
        exit 0
    fi

    # Running from /opt but not /opt/firstboot — don't mess with /opt
    if [[ "$FIRSTBOOT_RUN_DIR" == /opt/* ]]; then
        echo "Error: Running from $FIRSTBOOT_RUN_DIR — won't move from inside /opt."
        echo ""
        echo "  Move FirstBoot outside of /opt and re-run install.sh"
        echo "  Or manually move it: mv $FIRSTBOOT_RUN_DIR $INSTALL_DIR"
        echo ""
        exit 1
    fi

    # Target already exists
    if [ -d "$INSTALL_DIR" ]; then
        echo "Error: $INSTALL_DIR already exists."
        echo ""
        echo "  To reinstall:  rm -rf $INSTALL_DIR && bash install.sh"
        echo "  To update:     firstboot (use the Update option in the menu)"
        echo "  To run as-is:  firstboot"
        echo ""
        exit 1
    fi

    # Move into place
    mv "$FIRSTBOOT_RUN_DIR" "$INSTALL_DIR"
    ln -sf "$INSTALL_DIR/firstboot.sh" /usr/local/bin/firstboot

    echo ""
    echo "FirstBoot installed successfully."
    echo ""
}

run_firstboot_install