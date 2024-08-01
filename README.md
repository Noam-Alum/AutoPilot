# <img src="https://github.com/tandpfun/skill-icons/raw/main/icons/Linux-Dark.svg" width="38" style="max-width: 100%;"> New System

![made-with-bash](https://img.shields.io/badge/Made%20with-Bash-1f425f.svg)
![version](https://img.shields.io/static/v1?label=Version&message=1.0.0&color=green?style=plastic)

This script automates the setup of a new system with essential configurations.

---

##  <img src="https://cdn.iconscout.com/icon/premium/png-256-thumb/install-1462529-1238097.png?f=webp&w=256" width="24" style="max-width: 100%;"> Installation:

- **Git clone:**
  ```sh
  git clone https://github.com/Noam-Alum/new-system.git
  ```

- **wget:**
  ```sh
  wget https://github.com/Noam-Alum/new-system/archive/refs/heads/main.zip
  unzip main.zip
  ```

## <img src="https://cdn-icons-png.flaticon.com/512/5486/5486152.png" width="26" style="max-width: 100%;"> Usage:

> To use the script you first need to conduct a configuration file.

```sh
sudo ./new-system.sh configuration.yaml
```

---

## <img src="https://icons.iconarchive.com/icons/dtafalonso/android-lollipop/256/Settings-icon.png" width="26" style="max-width: 100%;"> Configuration

**new-system** uses *YAML* for its configuration file, for example:

```yaml
SELinux: Disabled

Installed_apps:
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
```

### Available directives:

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

* **Installed_apps:**
  - Which apps to install and how.
  - Format:
    ```yaml
    Installed_apps:
      - name: AnyName
        type: Deb/Pkg/Sh
        source: Deb name/Package url/Commands to run
    ```
  - Example:
    ```yaml
    Installed_apps:
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
