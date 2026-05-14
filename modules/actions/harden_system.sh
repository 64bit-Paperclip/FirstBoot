
# ---- Check if we are root.
harden_root_check(){
    
    if [is_user_root]; then

        warn "Hardening can not be perfromed as root."
        echo "One of the hardening steps is to disable root loging via ssh."

        if ! [has_sudo_users]; then
            echo "Please login as one of the users with sudo powers."
            
        else
            confirm_prompt "Would you like to create a super user now?" || { return 1;}
            action_create_super_user || { return 1;}
            echo ""
            echo "Exit FirstBoot, logout, then log back in as the new super user and run FirstBoot again."
            return 1;
        fi
    fi

}

harden_ufw_check(){
    if [is_ufw_installed]; then
        if ! [is_ufw_running]; then

        else

        fi

    else
    # --- offer to install ufw
        confirm_prompt "Would you like to install UFW?" || { return 1;}
        action_ufw_install
    fi
}


_harden_fail2ban_check(){

    if [is_fail2ban_installed]; then

        if [is_fail2ban_running]; then

        else

        fi

    else
        # --- offer to install fail2ban
        confirm_prompt "Would you like to install Fail2Ban?" || { return 1;}
        action_fail2ban_install
    fi

}

action_harden_system(){

    if ! [harden_root_check]; then
        warn "Hardening can not be perform until you are logged in as a non-root super user."
        return 1;
    fi

    local ssh_port
    ssh_port=$(get_ssh_port)

    if ! [harden_ufw_check]; then

        return 1;
    else

    fi

    if ! [_harden_fail2ban_check]; then

        return 1;
    else

    fi


}