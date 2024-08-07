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
uc_rn_err_msg="$error_prefix <biw>Error while executing</biw> <on_b><bw> {[ rn_cmd ]} </on_b></bw> <bw>{{ E-angry }}</bw>\n{{ BR-specialdots }}\n    <biw>Error:</biw>\n{{ BR-specialdots }}\n<on_ir><bw> {[ rn_err ]} </bw></on_ir>\n{{ BR-specialdots }}"

# Functions

## Fail
function fail {
  xecho "$error_prefix <biw>$2</biw> <bir>{{ E-fail }}</bir>"
  exit $1 
}

## Check dependencies
function check_dependencies {
  install_app="$1"
  install_msg="$2"
  install_cmd="$3"
  install_check="$4"
  if [ $($install_check &> /dev/null;echo $?) -ne 0 ];then
    xecho "$install_msg"
    run 0 noinfo "$install_cmd" && xecho "$good_prefix <biw>Installed \"$install_app\" successfully! {{ E-smile }}</biw>" || xecho "$error_prefix <biw>Could not install \"$install_app\" {{ E-sad }}</biw>"
  fi
}

function check_parsed_var {
  var_value="$(eval echo "\$$1")" 
  if [[ ! "$var_value" =~ ^($2)$ ]]; then
     xecho "$notgood_prefix <biw>Warning, \"$1\" directive cannot evaluate to \"$var_value\", skipping.</biw>"
  fi 
}

## Read configuration file
function parse_yaml {
  local configuration="$1"

  # Save variables from YAML

  ## Variables
  SELinux="$(yq '.SELinux' <<< "$configuration")"
  check_parsed_var "SELinux" "Enabled|Disabled|null"

  ## Arrays
  eval Run_Lines=($(yq -P '.Run_Lines' <<< "$configuration" | sed 's/^- //' | awk '{ gsub(/"/, "\\\""); print "\"" $0 "\"" }'))
  Installed_apps=($(yq -o=tsv '.Installed_apps[] | "\(.name),\(.type),\(.source)"' <<< "$configuration"))
  User_Pass=($(yq -o=tsv '.Users[] | "\(.pass)"' <<< "$configuration"))

  ## Dictionarys
  plugins_content="$(yq -o=tsv '.Plugins[] | "\(.name)=\(.script)"' <<< "$configuration")"
  if [ "$plugins_content" != "=" ]; then
    declare -gA Plugins
    while IFS= read -r line; do
      name=$(cut -d= -f1 <<< "$line")
      script=$(cut -d= -f2 <<< "$line")
      Plugins["$name"]="${script%.sh}"
    done <<< "$plugins_content"
  fi

  declare -gA Users
  local ui=0
  while IFS= read -r user; do
    name="$user"
    Users["$name"]="$ui"
    ui=$(( $ui + 1 ))
  done < <(yq -o=tsv '.Users[] | "\(.name)=\(.sudo)"' <<< "$configuration")
}

# Main
xecho "$banner"

## Check if the script is run as root
test "$UID" -ne 0 && fail 1 "Script must be run as root, exiting."

## Check dependencies
check_dependencies "yq" "$notgood_prefix <biw>Dependency missing, trying to install yq.</biw>" "curl -o '/usr/bin/yq' 'https://github.com/mikefarah/yq/releases/download/v4.44.2/yq_linux_amd64' && chmod +x /usr/bin/yq" "which yq"

## Get conf file
conf_file="$1"
test -z "$conf_file" && user_input conf_file "txt" "$info_prefix <biw>What configuration file would you like to use? : </biw>"
test -e "$conf_file" && configuration="$(cat $conf_file)" || fail 1 "Configuration file \"$conf_file\" not found, exiting."
yq_err="$(yq e . "$conf_file" 2>&1 > /dev/null)"
test -z "$yq_err" || fail 1 "Configuration fail is invaild: <on_b><bir>$yq_err</bir></on_b>"
parse_yaml "$configuration"

## Refresh package index
xecho "$info_prefix <biw>Refreshing local package index. {{ E-redo }}</biw>"
run 0 "noinfo" "apt-get update"

### SELinux
if [ "$SELinux" == "Enabled" ]; then
  xecho "$info_prefix <biw>Trying to enable {{ E-arrowright }} SELinux {{ E-arrowleft }} {{ E-nervous }}</biw>"
  check_dependencies "SELinux" "$notgood_prefix <biw>SELinux not found, tring to install, be patient. {{ E-angry }}</biw>" "apt -y install selinux-basics selinux-policy-default" "dpkg -L selinux-basics"
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

### Install apps
if [ "$Installed_apps" != ",," ]; then
  for app in "${Installed_apps[@]}"
  do
    app_name=$(awk -F, {'print $1'} <<< "$app")
    app_type=$(awk -F, {'print $2'} <<< "$app")
    app_source=$(awk -F, {'print $3'} <<< "$app")

    if [[ "null" =~ ^("$app_name"|"$app_type"|"$app_source")$ ]]; then
      xecho "$error_prefix <biw>Error while trying to install an app ($app_name ?), missing data. {{ E-sad }}</biw>"
    else
      xecho "$info_prefix <biw>Trying to install</biw> <biy>{{ E-star }}</biy> <biw>$app_name</biw> <biy>{{ E-star }}</biy> <biw>:</biw>"
      case $app_type in
        Deb)
          xecho "$info_prefix <biw>Using apt to install \"$app_name\", be patient.</biw>" 
          run 0 "noinfo" "apt -y install $app_source" && xecho "$good_prefix <biw>Installed \"$app_name\" successfully! {{ E-smile }}</biw>" || xecho "$error_prefix <biw>Could not install \"$app_name\" {{ E-sad }}</biw>"
          ;;
        Pkg)
          xecho "$info_prefix <biw>Fetching package from \"$app_source\".</biw>"
          ia_deb_package_name="$(gen_random str)_$app_name.deb"
          run 0 "noinfo" "curl -sLo /tmp/$ia_deb_package_name \"$app_source\" && dpkg -i /tmp/$ia_deb_package_name" && xecho "$good_prefix <biw>Installed \"$app_name\" successfully! {{ E-smile }}</biw>" || xecho "$error_prefix <biw>Could not install \"$app_name\" {{ E-sad }}</biw>"
          run 0 "noinfo" "apt-get install -f -y" && xecho "$info_prefix <biw>Tryed fixing dependency issues (if they exist.)"
          ;;
        Sh)
          xecho "$info_prefix <biw>Running installation script from \"$app_source\".</biw>"
          run 0 "noinfo" "curl -Ls \"$app_source\" | bash" && xecho "$good_prefix <biw>Installed \"$app_name\" successfully! {{ E-smile }}</biw>" || xecho "$error_prefix <biw>Could not install \"$app_name\" {{ E-sad }}</biw>"
          ;;
        *)
          xecho "$error_prefix <biw>Apps type is invaild \"$app_type\", skipping. (Use Deb/Pkg/Sh)</biw>"
          ;;
      esac
    fi
  done
fi

### Run lines
if [ "$Run_Lines" != "null" ]; then
  for rl_cmd in "${Run_Lines[@]}"; do
    run 0 "noinfo" "$rl_cmd" && xecho "$good_prefix <biw>Executed command: <on_b><bw>$rl_cmd</on_b></bw> <biw>successfully!</biw>." ||  xecho "$error_prefix <biw>Could not execute command: <on_b><bw>$rl_cmd</on_b></bw> {{ E-sad }}."
  done
fi

### Execute plugins
if [ ! -n "$Plugins" ]; then
  for plugin in ${!Plugins[@]}
  do
    if [ -e "${Plugins[$plugin]}/run.sh" ]; then
      if [ $(grep "run_$plugin" "${Plugins[$plugin]}/run.sh" &> /dev/null;echo $?) -eq 0 ]; then
        xecho "$good_prefix <biw>Executing plugin \"$plugin\":</biw>"
        source "${Plugins[$plugin]}/run.sh" &> /dev/null
        run_$plugin
      else
        xecho "$error_prefix <biw>Error while executing plugin \"$plugin\", could not find function: \"run_$plugin\".</biw>"
      fi
    else
      xecho "$error_prefix <biw>Error while executing plugin \"$plugin\", \"${Plugins[$plugin]}/run.sh\" does not exist.</biw>"
    fi
  done
fi

### Users
if [ ! -z "${User_Pass[0]}" ]; then
  for user in "${!Users[@]}"
  do
    username="$(awk -F= '{print $1}' <<< "$user")"
    usersudo="$(awk -F= '{print $2}' <<< "$user")"
    userpass="${User_Pass[${Users[$user]}]}"
    test "$userpass" == "%Gen%" && userpass="$(gen_random all)"
    xecho "$info_prefix <biw>Creating user \"$username\" (sudo? $usersudo).</biw>"
    if [ $(cat /etc/passwd | grep "$username:" &> /dev/null;echo $?) -ne 0 ]; then
  	  run 0 "noinfo" "useradd \"$username\"" && xecho "$good_prefix <biw>Added user \"$username\".</biw>" || xecho "$error_prefix <biw>Could not add user \"$username\".</biw>"
	    test "$usersudo" == "yes" && run 0 "noinfo" "usermod -aG sudo \"$username\""
  	  run 0 "noinfo" "echo -e \"$userpass\n$userpass\" | passwd $username"
    else
	  xecho "$notgood_prefix <biw>User exists alredy {{ E-angry }} {{ BR-scissors }} skipping.</biw>"
    fi
  done
fi
