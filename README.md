# New System


## Configuration file

The Configuration file is written in YAML, and can contain the following directives:

| **Directive**      | **Explenation**                                   | **Values**                                                                                              | **Example**                                                                                                                                                                                                                                                                                                                          |
|--------------------|---------------------------------------------------|---------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **SELinux**        | Whether SELinux is enabled or not.                | `Enabled`, `Disabled`                                                                                   | ```yaml<br>SELinux: Enabled<br>```                                                                                                                                                                                                                                                                                                   |
| **Run_Lines**      | When running the script, run the following lines. | Anything                                                                                                | ```yaml<br>Run_Lines:<br>  - echo "Hello"<br>  - echo "Hey"<br>```                                                                                                                                                                                                                                                                   |
| **Installed_apps** | Which apps to install and how.                    | - name: **AnyName**<br>  type: `Deb`/`Pkg`/`Sh`<br>  source: `Deb name`/`Package url`/`Installation script url` | ```yaml<br>Installed_apps:<br>  - name: FireJail<br>    type: Deb<br>    source: firejail<br>  - name: Discord<br>    type: Pkg<br>    source: https://discord.com/api/download?platform=linux&format=deb<br>  - name: NVIM<br>    type: Sh<br>    source: https://docs.alum.sh/files/NVIM-install.sh<br>``` |
| **Plugins**        | Which plugins to use and their location.          | Plugins:<br>  - name: **AnyName**<br>    script: `path/to/plugin/`                                      | ```yaml<br>- name: make_backup<br>	script: plugins/make_backup/install.sh<br>```                                                                                                                                                                                                                                                     |
