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

source utils.sh/utils-min.sh

# Style
## Prefixes
good_prefix=" <biw>{{ B-arrow }}</biw> <big>|</big>"
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
uc_rn_inf_msg="$good_prefix Executed <on_b><bw> {[ rn_cmd ]} </on_b></bw> successfully <big>{{ E-success }}</big>."
uc_rn_err_msg="$error_prefix Error while executing <on_b><bw> {[ rn_cmd ]} </on_b></bw> {{ E-angry }}\n{{ BR-heart }}\n    <bw>Error:</bw>\n{{ BR-heart }}\n<on_ir><bw> {[ rn_err ]} </bw></on_ir>\n{{ BR-heart }}"

# Functions

## Fail
function fail {
  xecho "$error_prefix $2 <bir>{{ E-fail }}</bir>"
  test -z "$1" && exit $1
}

## Check dependencies
function check_dependencies {
  if [ -z "$(which yq)" ];then
    xecho "$info_prefix Dependency missing, trying to install yq:"
    run 0 info "wget 'https://github.com/mikefarah/yq/releases/download/v4.44.2/yq_linux_amd64' -O /usr/local/bin/yq"
    run 0 info "chmod +x /usr/local/bin/yq"
  fi
}


## Read configuration file
parse_yaml() {
    local configuration="$1"

    # Save variables from YAML
    Is_secure=$(yq '.Is_secure' <<< "$configuration")
}

### TO DO

# Main

xecho "$banner"

## Check dependencies
check_dependencies

## Get conf file
conf_file="$1"
test -z "$conf_file" && user_input conf_file "txt" "$info_prefix What configuration file would you like to use? : "
test -e "$conf_file" && configuration="$(cat $conf_file)" || fail 1 "Configuration file \"$conf_file\" not found, exiting."
parse_yaml "$configuration"

echo "$Is_secure"
