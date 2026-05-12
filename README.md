# FirstBoot

A modular, interactive server management toolkit for Debian-based Linux systems. Run it on a fresh VPS and walk through setting up exactly what you need — mail server, web server, database, security hardening — through a clean terminal menu. Come back later to manage, reconfigure, or expand.

No web panel. No bloat. Just bash.

---

## What It Does

Setting up a Linux server from scratch means remembering the right sequence of commands, config file locations, security steps, and gotchas. FirstBoot handles that for you.

Pick what you want to install from a menu. Answer the questions. Get a correctly configured, production-ready service. Come back when you need to add something, change something, or check on something.

**Currently supported:**

- **Security** — SSH hardening, UFW firewall, Fail2ban, unattended security updates
- **Mail** — Postfix, Dovecot, OpenDKIM, Rspamd, ClamAV, virtual mailboxes via MySQL
- **Web** — Nginx, Apache, SSL via Certbot, virtual host management
- **Database** — MySQL, MariaDB, PostgreSQL, MongoDB
- **Other** — Redis, Docker, Node.js, PHP-FPM, Supervisor

---

## Requirements

- Debian-based Linux (Ubuntu, Debian, Linux Mint, Pop!_OS etc.)
- systemd
- bash 4.2+
- Root or sudo access
- Internet connection

> Tested on Ubuntu 24.04 LTS. Other Debian-based distributions should work but are not officially supported.

---

## Installation

```bash
# Download
curl -L -o firstboot.zip https://github.com/64bit-Paperclip/FirstBoot/archive/refs/heads/master.zip

# Install unzip if needed
sudo apt update && sudo apt install -y unzip

# Extract
unzip firstboot.zip && mv FirstBoot-master FirstBoot

# Run
cd FirstBoot && sudo bash ./firstboot.sh
```

---

## How It Works

FirstBoot is built around three concepts:

**Groups** are curated collections of related services. The Mail group gives you access to Postfix, Dovecot, OpenDKIM, Rspamd, and everything else a mail server needs, in one place, in the right order.

**Services** are individual components you can manage independently. Each service has its own intelligent menu that reflects current state. If MySQL isn't installed, you see an install option. If it is installed and running, you see database management, user management, and configuration options.

**Actions** are individual tasks. Creating a database, adding a mailbox, renewing a certificate, banning an IP. Actions registered by services are also accessible directly from the main Actions menu, so you can get to anything without navigating through menus.

---

## Directory Structure

```
firstboot.sh
lib/
  ui.sh               -- UI functions, menus, section headers
  globals.sh          -- Global variables and system detection
  groups.sh           -- Group registration and loading
  services.sh         -- Service registration and loading
  actions.sh          -- Action registration and loading
  status.sh           -- System status display
modules/
  groups/
    database/         -- MySQL, MariaDB, PostgreSQL, MongoDB
    mail/             -- Postfix, Dovecot, OpenDKIM, Rspamd
    security/         -- UFW, Fail2ban, Certbot
    web/              -- Nginx, Apache
  services/
    mysql/            -- MySQL management
    nginx/            -- Nginx management
    fail2ban/         -- Fail2ban management
    ufw/              -- UFW management
    ...
  actions/            -- Standalone install/uninstall actions
```

---

## Extending FirstBoot

FirstBoot is designed to be extended. Modules are self-registering -- drop a new directory into `modules/services/` and it automatically appears in the menu next time you start.

### Adding a Service

1. Create `modules/services/myservice/myservice.sh`
2. Define your service variables, utility functions, menu options, and entry function:

```bash
MYSERVICE_LABEL="My Service"
MYSERVICE_SERVICE="myservice"
MYSERVICE_PACKAGE="mypackage"
MYSERVICE_SVC_VAR="SVC_MYSERVICE"
MYSERVICE_GROUP="mygroup"
MYSERVICE_ENTRY="myservice_entry"

SVC_MYSERVICE="not installed"

MYSERVICE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source_service_actions "$MYSERVICE_DIR"

register_service "$MYSERVICE_LABEL|$MYSERVICE_SERVICE|$MYSERVICE_PACKAGE|$MYSERVICE_SVC_VAR|$MYSERVICE_GROUP|$MYSERVICE_ENTRY"

is_myservice_installed() { pkg_installed "$MYSERVICE_PACKAGE"; }
is_myservice_running()   { svc_running "$MYSERVICE_SERVICE"; }

myservice_entry() {
    command_menu MYSERVICE_MENU_OPTIONS "My Service"
}
```

3. Add action scripts in `modules/services/myservice/actions/`
4. Each action registers itself:

```bash
action_myservice_install() {
    # install logic
}
register_action "Install My Service|myservice_install|action_myservice_install"
```

### Adding a Group

1. Create `modules/groups/mygroup/mygroup.sh`
2. Define an entry function that dynamically builds its menu from registered services:

```bash
setup_mygroup() {
    local -a _MYGROUP_OPTIONS=()
    for entry in "${SERVICES[@]}"; do
        IFS='|' read -r label svc pkg svcvar groups entry_fn <<< "$entry"
        if [[ ",$groups," == *",mygroup,"* ]]; then
            _MYGROUP_OPTIONS+=("$label|$entry_fn")
        fi
    done
    command_menu _MYGROUP_OPTIONS "My Group"
}

register_group "My Group|mygroup|setup_mygroup"
```

---

## Author

Jason Penick
GitHub: [64bit-Paperclip](https://github.com/64bit-Paperclip)

