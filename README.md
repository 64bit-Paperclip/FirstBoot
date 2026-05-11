# FirstBoot

**Server setup and management toolkit for Ubuntu 24.04 LTS.**

FirstBoot is an interactive, modular server management script. It handles initial server hardening, service installation, and ongoing management through a clean menu-driven interface. Services, groups, and actions are self-registering — adding a new module automatically makes it available in the menu.

---

## Requirements

- Debian-based Linux (Ubuntu, Debian, Linux Mint, Pop!_OS etc.)
- systemd
- bash 4.0+
- Root or sudo access
- Internet connection

> Tested on Ubuntu 24.04 LTS. Other Debian-based distributions should work but are not officially supported.

## Installation

### 1. Download

```bash
curl -L -o firstboot.zip https://github.com/64bit-Paperclip/FirstBoot/archive/refs/heads/master.zip
```

### 2. Install unzip if needed

```bash
apt install unzip -y
```

### 3. Extract

```bash
unzip firstboot.zip
cd FirstBoot-master
```

### 4. Run

```bash
sudo bash firstboot.sh
```

---

## Directory Structure

```
firstboot.sh              — Master script
lib/
  common.sh               — Colors, info/warn/error/section functions
  globals.sh              — Global variables and detection functions
  groups.sh               — Group registration and loading
  services.sh             — Service registration and loading
  actions.sh              — Action registration and loading
  status.sh               — System status display
  ui.sh                   — Menu and UI functions
modules/
  groups/
    database/             — Database group (MySQL, MariaDB, PostgreSQL, MongoDB)
    mail/                 — Mail group (Postfix, Dovecot, OpenDKIM, Rspamd)
    security/             — Security group (UFW, Fail2ban, Certbot)
    web/                  — Web group (Nginx, Apache)
  services/
    fail2ban/             — Fail2ban service module
    mysql/                — MySQL service module
    nginx/                — Nginx service module
    ufw/                  — UFW service module
    ...
  actions/                — Standalone actions (install, uninstall, etc.)
```

---

## How It Works

### Groups
Groups are curated stacks of services that work together. Selecting a group from the menu installs and configures everything needed for that role. For example, the **Mail** group installs and configures Postfix, Dovecot, OpenDKIM, Rspamd, Redis, and Certbot together.

### Services
Individual services can be managed independently — install, uninstall, configure, and run service-specific actions like creating databases or managing users.

### Actions
Standalone tasks that don't belong to a specific service — things like installing or uninstalling a package, creating a mailbox, or renewing certificates.

### Self-Registering Modules
Each module registers itself when sourced at startup. Adding a new service is as simple as dropping a new directory into `modules/services/` — it automatically appears in the menu.

---

## Adding a New Service

1. Create a directory: `modules/services/myservice/`
2. Create the main script: `modules/services/myservice/myservice.sh`
3. Define an entry function and register the service:

```bash
myservice_entry() {
    command_menu MYSERVICE_MENU_OPTIONS "My Service"
}

register_service "My Service|myservice|mypackage|SVC_MYSERVICE|mygroup|myservice_entry"
```

4. Optionally add action scripts in `modules/services/myservice/actions/`

---

## Adding a New Group

1. Create a directory: `modules/groups/mygroup/`
2. Create the main script: `modules/groups/mygroup/mygroup.sh`
3. Define an entry function and register the group:

```bash
setup_mygroup() {
    local -a MYGROUP_MENU_OPTIONS=()
    for entry in "${SERVICES[@]}"; do
        IFS='|' read -r label svc pkg svcvar groups entry_fn <<< "$entry"
        if [[ ",$groups," == *",mygroup,"* ]]; then
            MYGROUP_MENU_OPTIONS+=("$label|$entry_fn")
        fi
    done
    command_menu MYGROUP_MENU_OPTIONS "My Group"
}

register_group "My Group|mygroup|setup_mygroup"
```

---

## Author

Jason Penick
GitHub: [64bit-Paperclip](https://github.com/64bit-Paperclip)

---

## License

MIT