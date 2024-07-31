# New System


## Configuration file

The Configuration file is written in YAML, and can contain the following directives:

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
        script: path/to/plugin/
    ```
  - Example:
    ```yaml
    Plugins:
      - name: make_backup
        script: plugins/make_backup/install.sh
    ```
