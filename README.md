# AutoPilot <img src="https://docs.alum.sh/images/AutoPilot-Icons/AutoPilot-icon-color.png" width="38" style="max-width: 100%;"> It's simple.
![made-with-bash](https://img.shields.io/badge/Made%20with-Bash-blue?style=plastic&labelColor=%237b7b7b&color=%23003972)
[![made-with-utils.sh](https://img.shields.io/badge/Made%20with-utils.sh-blue?style=plastic&labelColor=%237b7b7b&color=%23003972)](https://github.com/Noam-Alum/utils.sh)
![version](https://img.shields.io/badge/Version-1.0.0-blue?style=plastic&labelColor=%2390ee90&color=%23003972)

**AutoPilot** is a free to use [bash](https://en.wikipedia.org/wiki/Bash_(Unix_shell)) script written by [Noam Alum](https://www.linkedin.com/in/noam-alum/) meant to automate the process of setting up a new system.<br>
It uses [YAML](https://en.wikipedia.org/wiki/YAML) for its configuration file, so it is very easy to set up, and you can create numerous configuration files for different occasions. (I like to call them *"Profiles"* 🙃)

![AutoPilotBanner](https://docs.alum.sh/images/AutoPilot-Logo.png)

> [!NOTE]
> This script relies heavily on a collection of functions, `utils.sh`.
> 
> https://github.com/Noam-Alum/AutoPilot/blob/8a05103fdd2deaaf2c534efd20c3c6fe5dbd2e04/AutoPilot.sh#L11-L13
> 
> <br>
> 
> [![ReadMe Card](https://github-readme-stats.vercel.app/api/pin?username=Noam-Alum&repo=utils.sh&title_color=fff&icon_color=f9f9f9&text_color=9f9f9f&bg_color=151515)](https://github.com/Noam-Alum/utils.sh)

<br>

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

> [!WARNING]
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

> **For detailed documentation on every directive:**
> 
> [![Button Component](https://readme-components.vercel.app/api?component=button&text=Documentation)](https://docs.alum.sh/AutoPilot/Introduction.html)

<br>

---

## <img src="https://www.freeiconspng.com/thumbs/helping-hand-icon-png/helping-hand-icon-png-25.png" width="26" style="max-width: 100%;"> Contribute

Any contribution would be greatly appreciated, refer to [this page](CONTRIBUTING.md) for detailed guides on how to contribute.

<br>

> [!NOTE]
> **If you want to request a new feature, you can do that [here](https://github.com/Noam-Alum/AutoPilot/issues/new?assignees=Noam-Alum&labels=feature+request&projects=&template=feature-request.md&title=Feature+request+%7C+%5Bfeature+request+short+description%5D).**
