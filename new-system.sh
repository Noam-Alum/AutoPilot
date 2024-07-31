#!/bin/bash
# 
# **new_system.sh**
#
# | Authors: Noam Alum, Shay Aviv
# | Created: July 30, 2024
# | Last modified: July 30, 2024
# | Version: 1.0
# | Description: This script automates the setup of a new system with essential configurations.
#

source <(curl -Ls "https://raw.githubusercontent.com/Noam-Alum/utils.sh/main/utils.sh")

# Style
## Prefixes
good_prefix=" <biw>{{ B-arrow }}</biw> <big>|</big>"
notgood_prefix=" <biw>{{ B-arrow }}</biw> <biy>|</biy>"
error_prefix=" <biw>{{ B-arrow }}</biw> <bir>|</bir>"
info_prefix=" <biw>{{ B-arrow }}</biw> <biw>|</biw>"

## Banner
banner="
<bic>███╗   ██╗███████╗██╗    ██╗    ███████╗██╗   ██╗███████╗████████╗███████╗███╗   ███╗
████╗  ██║██╔════╝██║    ██║    ██╔════╝╚██╗ ██╔╝██╔════╝╚══██╔══╝██╔════╝████╗ ████║
██╔██╗ ██║█████╗  ██║ █╗ ██║    ███████╗ ╚████╔╝ ███████╗   ██║   █████╗  ██╔████╔██║
██║╚██╗██║██╔══╝  ██║███╗██║    ╚════██║  ╚██╔╝  ╚════██║   ██║   ██╔══╝  ██║╚██╔╝██║
██║ ╚████║███████╗╚███╔███╔╝    ███████║   ██║   ███████║   ██║   ███████╗██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚══╝╚══╝     ╚══════╝   ╚═╝   ╚══════╝   ╚═╝   ╚══════╝╚═╝     ╚═╝</bic>

                    <biy>{{ E-cloud }}</biy>  <bir>By: Shay Aviv and Noam Alum.</bir> <biy>{{ E-cloud }}</biy>\n"

## UC variables
### if_continue
uc_ifc_posfix="<big>yes {{ E-success }}</big>|<bir>no {{ E-fail }}</bir> | "

### gen_random
uc_gr_len=14

### run
uc_rn_inf_msg="$good_prefix <biw>Executed</biw> <on_b><bw> {[ rn_cmd ]} </on_b></bw> <biw>successfully</biw> <big>{{ E-success }}</big>."
uc_rn_err_msg="$error_prefix <biw>Error while executing</biw> <on_b><bw> {[ rn_cmd ]} </on_b></bw> {{ E-angry }}\n{{ BR-bear }}\n    <biw>Error:</biw>\n{{ BR-bear }}\n<on_ir><bw> {[ rn_err ]} </bw></on_ir>\n{{ BR-bear }}"

# Functions

## Fail
function fail {
  xecho "$error_prefix $2 <bir>{{ E-fail }}</bir>"
  exit $1 
}

## Check dependencies
function check_dependencies {
  if [ -z "$1" ]; then
    if [ -z "$(which yq 2> /dev/null)" ];then
      xecho "$notgood_prefix Dependency missing, trying to install yq:"
      run 0 info "wget 'https://github.com/mikefarah/yq/releases/download/v4.44.2/yq_linux_amd64' -O /usr/local/bin/yq"
      run 0 info "chmod +x /usr/local/bin/yq"
    fi
  else
    install_msg="$1"
    install_cmd="$2"
    xecho "$notgood_prefix <biw>$install_msg</biw>"
    run 0 info "$install_cmd"
  fi
}

## Read configuration file
function parse_yaml {
  local configuration="$1"

  # Save variables from YAML

  ## Variables
  SELinux=$(yq '.SELinux' <<< "$configuration")
  if [[ ! "$SELinux" =~ ^(Enabled|Disabled)$ ]]; then
    xecho "$notgood_prefix Warning, SELinux directive cannot evaluate to \"$SELinux\", skipping."
  fi

  ## Arrays
  eval Run_Lines=($(yq -P '.Run_Lines' <<< "$configuration" | sed 's/^- //' | awk '{ gsub(/"/, "\\\""); print "\"" $0 "\"" }'))
  Installed_apps=($(yq -o=tsv '.Installed_apps[] | "\(.name)=\(.type)=\(.source)"' <<< "$configuration"))

  ## Dictionarys
  declare -gA Plugins
  while IFS= read -r line; do
    name=$(cut -d= -f1 <<< "$line")
    script=$(cut -d= -f2 <<< "$line")
    Plugins["$name"]="${script%.sh}"
  done < <(yq -o=tsv '.Plugins[] | "\(.name)=\(.script)"' <<< "$configuration")
}

# Main
xecho "$banner"

## Check if the script is run as root
test "$UID" -ne 0 && fail 1 "Script must be run as root, exiting."

## Check dependencies
check_dependencies

## Get conf file
conf_file="$1"
test -z "$conf_file" && user_input conf_file "txt" "$info_prefix What configuration file would you like to use? : "
test -e "$conf_file" && configuration="$(cat $conf_file)" || fail 1 "Configuration file \"$conf_file\" not found, exiting."
parse_yaml "$configuration"

### SELinux
if [ ! -z "$SELinux" ]; then
  if [ "$SELinux" == "Enabled" ]; then
    xecho "$info_prefix <biw>Trying to enable {{ E-arrowright }} SELinux {{ E-arrowleft }} {{ E-nervous }}</biw>"

    if [ "$(dpkg -L selinux-basics &> /dev/null; echo $?)" -ne 0 ]; then
      check_dependencies "SELinux not found, tring to install, be patient. {{ E-angry }}" "apt -y install selinux-basics selinux-policy-default"
    fi

    sed -i 's/^SELINUX=.*$/SELINUX=enforcing/' /etc/selinux/config
    grep "SELINUX=enforcing" /etc/selinux/config &> /dev/null && xecho "$good_prefix <biw>SELinux enabled successfully. {{ E-smile }}</biw>"
  elif [ "$SELinux" == "Disabled" ]; then
    xecho "$info_prefix <biw>Trying to disable {{ E-arrowright }} SELinux {{ E-arrowleft }} {{ E-nervous }}</biw>"
    if [ "$(dpkg -L selinux-basics &> /dev/null; echo $?)" -ne 0 ]; then
      xecho "$good_prefix <biw>SELinux is not installed, no need to disable {{ E-smile }}</biw>"
    else
      sed -i 's/^SELINUX=.*$/SELINUX=disabled/' /etc/selinux/config
      grep "SELINUX=disabled" /etc/selinux/config &> /dev/null && xecho "$good_prefix <biw>SELinux disabled successfully. {{ E-smile }}</biw>"
    fi
  fi
fi
