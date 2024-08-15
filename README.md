# <img src="https://github.com/tandpfun/skill-icons/raw/main/icons/Linux-Dark.svg" width="38" style="max-width: 100%;"> AutoPilot
![made-with-bash](https://img.shields.io/badge/Made%20with-Bash-blue?style=plastic&labelColor=%237b7b7b&color=%23003972)
[![made-with-utils.sh](https://img.shields.io/badge/Made%20with-utils.sh-blue?style=plastic&labelColor=%237b7b7b&color=%23003972)](https://github.com/Noam-Alum/utils.sh)
![version](https://img.shields.io/badge/Version-1.0.0-blue?style=plastic&labelColor=%2390ee90&color=%23003972)

This script automates the setup of a new system with essential configurations, and relies heavily on a collection of functions, `utils.sh`.

https://github.com/Noam-Alum/AutoPilot/blob/8a05103fdd2deaaf2c534efd20c3c6fe5dbd2e04/AutoPilot.sh#L11-L13

<br>

[![Button Component](https://readme-components.vercel.app/api?component=button&text=Go-to-utils.sh)](https://github.com/Noam-Alum/utils.sh)

---

##  <img src="https://cdn.iconscout.com/icon/premium/png-256-thumb/install-1462529-1238097.png?f=webp&w=256" width="24" style="max-width: 100%;"> Installation:

- **Git clone:**
  ```sh
  git clone https://github.com/Noam-Alum/AutoPilot.git
  ```

- **wget:**
  ```sh
  wget https://github.com/Noam-Alum/AutoPilot/archive/refs/heads/main.zip
  unzip main.zip
  ```

## <img src="https://cdn-icons-png.flaticon.com/512/5486/5486152.png" width="26" style="max-width: 100%;"> Usage:

> To use the script you first need to conduct a configuration file.

```sh
sudo ./AutoPilot.sh configuration.yaml
```

---

## <img src="https://icons.iconarchive.com/icons/dtafalonso/android-lollipop/256/Settings-icon.png" width="26" style="max-width: 100%;"> Configuration

**AutoPilot** uses *YAML* for its configuration file, for example:

```yaml
SELinux: Disabled

Installed_packages:
  - name: FireJail
    type: Deb
    source: firejail
  - name: Discord
    type: Pkg
    source: "https://discord.com/api/download?platform=linux&format=deb"
  - name: NVIM
    type: Sh
    source: "https://docs.alum.sh/files/NVIM-install.sh"
  - name: Chrome
    type: Pkg
    source: https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  - name: git
    type: Deb
    source: git

Run_Lines:
  - echo "Hello"
  - echo "Hello world"

Plugins:
  - name: FireJail
    script: plugins/firejail
  - name: make_backup
    script: plugins/make_backup

Network_Configuration:
  - nic: tun0
    ip: 192.168.2.14/24
    gateway: 192.168.2.1
    dns: 8.8.8.8,8.4.8.4
  - nic: eth0
    ip: "%DHCP%"
    gateway: "%DHCP%"
    dns: "%DHCP%"
```

### Available directives:

* **Users:**
  - Add users, set their passwords, and whether they have sudo privileges.<br>
    Use `%Gen%` to generate a password.
  - Format:
    ```yaml
    Users:
      - name: USERNAME
      - pass: PASSWORD/%Gen%
      - sudo: Yes/No
    ```
  - Example:
    ```yaml
      Users:
        - name: Noam
        - pass: 1234
        - sudo: Yes
        - name: Shay
        - pass: %Gen%
        - sudo: No
    ```

* **SELinux:**
  - Whether SELinux is enabled or not.
  - Values: `Enabled`, `Disabled`
  - Example:
    ```yaml
    SELinux: Enabled
    ```

* **Run_Lines:**
  - When running the script, run the following lines. (Try to keep each line small, for big shell access consider creating a plugin)
  - Values: Anything
  - Example:
    ```yaml
    Run_Lines:
      - echo "Hello"
      - echo "Hey"
    ```

* **Installed_packages:**
  - Which packages to install and how.
  - Format:
    ```yaml
    Installed_packages:
      - name: AnyName
        type: Deb/Pkg/Sh
        source: Deb name/Package url/Commands to run
    ```
  - Example:
    ```yaml
    Installed_packages:
      - name: FireJail
        type: Deb
        source: firejail
      - name: Discord
        type: Pkg
        source: https://discord.com/api/download?platform=linux&format=deb
      - name: NVIM
        type: Sh
        source: git clone https://github.com/NvChad/starter ~/.config/nvim && nvim
    ```

* **Plugins:**
  - Which plugins to use and their location.
  - Format:
    ```yaml
    Plugins:
      - name: AnyName
        script: path/to/plugin/run.sh
    ```
  - Example:
    ```yaml
    Plugins:
      - name: make_backup
        script: plugins/make_backup/run.sh
    ```

* **Network_Configuration:**
    - Per NIC simple configuration.<br>
      Use `"%DHCP%"`, to use dhcp. (If used at any of the entries dhcp would be used on the whole nic.)
    - Format:
      ```yaml        
      Network_Configuration:
        - nic: INTERFACE
          ip: IP_ADDRESS/PREFIX
          gateway: GATEWAY_ADDRESS
          dns: DNS1,DNS2,DNS3
      ```
    - Example:
      ```yaml 
      Network_Configuration:
        - nic: tun0
          ip: 192.168.2.14/24
          gateway: 192.168.2.1
          dns: 8.8.8.8,8.4.8.4
        - nic: eth0
          ip: "%DHCP%"
          gateway: "%DHCP%"
          dns: "%DHCP%
      ```
