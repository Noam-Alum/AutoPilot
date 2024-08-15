#!/bin/bash
# 
# **AutoPilot.sh**
#
# | Author: Noam Alum
# | Created: July 30, 2024
# | Last modified: Thu Aug 15, 2024
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
banner="<bic>
────────────────────────────────────────────────────────────────────────────

   █████╗ ██╗   ██╗████████╗ ██████╗ ██████╗ ██╗██╗      ██████╗ ████████╗
  ██╔══██╗██║   ██║╚══██╔══╝██╔═══██╗██╔══██╗██║██║     ██╔═══██╗╚══██╔══╝
  ███████║██║   ██║   ██║   ██║   ██║██████╔╝██║██║     ██║   ██║   ██║   
  ██╔══██║██║   ██║   ██║   ██║   ██║██╔═══╝ ██║██║     ██║   ██║   ██║   
  ██║  ██║╚██████╔╝   ██║   ╚██████╔╝██║     ██║███████╗╚██████╔╝   ██║   
  ╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝ ╚═╝     ╚═╝╚══════╝ ╚═════╝    ╚═╝ 

──────────────────────────┐</bic><biy>{{ E-cloud }}</biy>  <biw>By: Noam Alum.</biw> <biy>{{ E-cloud }}</biy><bic> ┌─────────────────────────────</bic>\n"

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

function parse_yaml {
  local yaml_mode="$1"
  local yaml_1="$2"

  case $yaml_mode in
    keys)
      local yaml_2="$3"
 	    yq --output-format tsv ".$yaml_1[].$yaml_2" <<< "$configuration" 2> /dev/null
 	    ;;
    0)
      eval $yaml_1="$(printf '%q' "$(yq ".$yaml_1" <<< "$configuration" 2> /dev/null)")"
      ;;
    1)
      eval "$yaml_1=()"
      local yaml_2="$(yq ".$yaml_1[]" <<< "$configuration" 2> /dev/null)"
      while IFS= read -r line; do
        eval "$yaml_1+=('$(printf '%q' "$line" | sed 's/\\ / /g')')"
      done <<< "$yaml_2"
      ;;
    2)
      local yaml_2="$3"
  	  local yaml_3=($(parse_yaml keys "$yaml_1" "$yaml_2"))
  	  local yaml_4="$4"
  	  declare -gA "$yaml_1"
  	  for item in "${yaml_3[@]}"
  	  do
        eval $yaml_1["$item"]="$(printf '%q' "$(yq eval ".$yaml_1[] | select(.$yaml_2 == \"$item\") | .$yaml_4" <<< "$configuration" 2> /dev/null)")"
  	  done
      ;;
    3)
      local yaml_2="$3"
      local yaml_3=($(yq -o=tsv ".$yaml_1[] | \"\(.$yaml_2)\"" <<< "$configuration" 2> /dev/null))
      local yaml_4="$4"
      local yaml_5="$5"
      declare -gA "$yaml_1"
  	  for item in "${yaml_3[@]}"
  	  do
        eval $yaml_1["$item [0]"]="$(printf '%q' "$(yq eval ".$yaml_1[] | select(.$yaml_2 == \"$item\") | .$yaml_4" <<< "$configuration" 2> /dev/null)")"
        eval $yaml_1["$item [1]"]="$(printf '%q' "$(yq eval ".$yaml_1[] | select(.$yaml_2 == \"$item\") | .$yaml_5" <<< "$configuration" 2> /dev/null)")"
  	  done
      ;;
    4)
      local yaml_2="$3"
      local yaml_3=($(yq -o=tsv ".$yaml_1[] | \"\(.$yaml_2)\"" <<< "$configuration" 2> /dev/null))
      local yaml_4="$4"
      local yaml_5="$5"
      local yaml_6="$6"
      declare -gA "$yaml_1"
  	  for item in "${yaml_3[@]}"
  	  do
        eval $yaml_1["$item [0]"]="$(printf '%q' "$(yq eval ".$yaml_1[] | select(.$yaml_2 == \"$item\") | .$yaml_4" <<< "$configuration" 2> /dev/null)")"
        eval $yaml_1["$item [1]"]="$(printf '%q' "$(yq eval ".$yaml_1[] | select(.$yaml_2 == \"$item\") | .$yaml_5" <<< "$configuration" 2> /dev/null)")"
        eval $yaml_1["$item [2]"]="$(printf '%q' "$(yq eval ".$yaml_1[] | select(.$yaml_2 == \"$item\") | .$yaml_6" <<< "$configuration" 2> /dev/null)")"
  	  done
      ;;
  esac
}

## Run functions
function rn_Network_Configuration {
  parse_yaml 4 Network_Configuration nic ip gateway dns
  check_dependencies "network-manager" "$notgood_prefix <biw>Dependency missing, trying to install network-manager.</biw>" "apt install -yq network-manager &> /dev/null" "which nmcli"

  if [ ${#Network_Configuration[@]} -ne 0 ]; then
    if [ $(grep -E '^\[keyfile\]|unmanaged-devices=' /etc/NetworkManager/NetworkManager.conf &> /dev/null;echo $?) -eq 0 ]; then
      run 0 "noinfo" "sudo sed -i 's/^\(unmanaged-devices\s*=\s*\).*/\1none/' /etc/NetworkManager/NetworkManager.conf"
    else
      echo -e "\n[keyfile]\nunmanaged-devices=none" >> /etc/NetworkManager/NetworkManager.conf
    fi
    run 0 "noinfo" "systemctl restart NetworkManager"

    NC_keys=($(tr ' ' '\n' <<< "${!Network_Configuration[@]}" | grep -Ev '\[(0|1|2)\]' | sort -u))
    for nic in "${NC_keys[@]}"
    do
      nic_ip="${Network_Configuration["$nic [0]"]}"
      nic_gateway="${Network_Configuration["$nic [1]"]}"
      nic_dns="${Network_Configuration["$nic [2]"]}"

      xecho "$info_prefix <biw>Modifying connection named \"$nic\"</biw>"

      if [[ "%DHCP%" =~ ^("$nic_ip"|"$nic_dns"|"$nic_gateway")$ ]]; then
        if nmcli connection show "$nic" &> /dev/null; then
          run 0 "noinfo" "nmcli connection modify \"$nic\" ipv4.method auto" && xecho "$info_prefix <biw>Modified connection named \"$nic\" to use DHCP.</biw> <bip>{{ E-sleep }}</bip>" ||  xecho "$notgood_prefix <biw>Could not modify connection named \"$nic\" to use DHCP. {{ E-nervous }}</biw>" 
        else
          xecho "$info_prefix <biw>Could not find a connection named \"$nic\" trying to create one. {{ E-nervous }}</biw>"
          run 0 "noinfo" "nmcli connection add type ethernet ifname \"$nic\" con-name "$nic" ipv4.method auto" && xecho "$info_prefix <biw>Modified connection named \"$nic\" to use DHCP.</biw> <biy>{{ E-star }}</biy>" ||  xecho "$notgood_prefix <biw>Could not modify connection named \"$nic\" to use DHCP. {{ E-nervous }}</biw>"
        fi
        run 0 "noinfo" "nmcli connection up \"$nic\"" && xecho "$good_prefix <biw>Nic $nic is now using DHCP.</biw> <big>{{ E-success }}</big>" || xecho "$error_prefix <biw>Could not bring up connection named \"$nic\"</biw> <bir>{{ E-fail }}</bir>"
      else
        if nmcli connection show "$nic" &> /dev/null; then
          run 0 "noinfo" "nmcli connection modify $nic ipv4.addresses $nic_ip ipv4.gateway $nic_gateway ipv4.dns \"$nic_dns\" ipv4.method manual" && xecho "$info_prefix <biw>Modified connection named \"$nic\",</biw> <bip>IP=$nic_ip, GATEWAY=$nic_gateway, DNS=$nic_dns</bip><biw>.</biw> <biy>{{ E-star }}</biy>" ||  xecho "$notgood_prefix <biw>Could not modify connection named \"$nic\", <bip>IP=$nic_ip, GATEWAY=$nic_gateway, DNS=$nic_dns</bip><biw>. {{ E-nervous }}</biw>"
        else
          xecho "$info_prefix <biw>Could not find a connection named \"$nic\" trying to create one. {{ E-nervous }}</biw>"
          run 0 "noinfo" "nmcli connection add type ethernet con-name $nic ifname $nic ipv4.addresses $nic_ip ipv4.gateway $nic_gateway ipv4.dns \"$nic_dns\" ipv4.method manual" && xecho "$info_prefix <biw>Modified connection named \"$nic\",</biw> <bip>IP=$nic_ip, GATEWAY=$nic_gateway, DNS=$nic_dns</bip><biw>.</biw> <biy>{{ E-star }}</biy>" ||  xecho "$notgood_prefix <biw>Could not modify connection named \"$nic\", <bip>IP=$nic_ip, GATEWAY=$nic_gateway, DNS=$nic_dns</bip><biw>. {{ E-nervous }}</biw>"
        fi
        run 0 "noinfo" "nmcli connection up \"$nic\"" && xecho "$good_prefix <biw>Nic $nic is now manually configured.</biw> <big>{{ E-success }}</big>" || xecho "$error_prefix <biw>Could not bring up connection named \"$nic\"</biw> <bir>{{ E-fail }}</bir>"
      fi
    done
  fi
}

function rn_SELinux {
  parse_yaml 0 SELinux
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
}

function rn_Installed_packages {
  parse_yaml 3 Installed_packages name type source
  if [ "${#Installed_packages[@]}" -ne 0 ]; then
    IP_keys=($(tr ' ' '\n' <<< "${!Installed_packages[@]}" | grep -Ev '\[(0|1)\]' | sort -u))
    for pkg in "${IP_keys[@]}"
    do
      pkg_type="${Installed_packages["$pkg [0]"]}"
      pkg_source="${Installed_packages["$pkg [1]"]}"

      if [[ '' =~ ^("$pkg"|"$pkg_type"|"$pkg_source")$ ]]; then
        xecho "$error_prefix <biw>Error while trying to install an package ($pkg ?), missing data. {{ E-sad }}</biw>"
      else
        xecho "$info_prefix <biw>Trying to install</biw> <biy>{{ E-star }}</biy> <biw>$pkg</biw> <biy>{{ E-star }}</biy> <biw>:</biw>"
        case $pkg_type in
          Deb)
            xecho "$info_prefix <biw>Using apt to install \"$pkg\", be patient.</biw>" 
            run 0 "noinfo" "apt -y install $pkg_source" && xecho "$good_prefix <biw>Installed \"$pkg\" successfully! {{ E-smile }}</biw>" || xecho "$error_prefix <biw>Could not install \"$pkg\" {{ E-sad }}</biw>"
            ;;
          Pkg)
            xecho "$info_prefix <biw>Fetching package from \"$pkg_source\".</biw>"
            ia_deb_package_name="$(gen_random str)_$pkg.deb"
            run 0 "noinfo" "curl -sLo /tmp/$ia_deb_package_name \"$pkg_source\" && dpkg -i /tmp/$ia_deb_package_name" && xecho "$good_prefix <biw>Installed \"$pkg\" successfully! {{ E-smile }}</biw>" || xecho "$error_prefix <biw>Could not install \"$pkg\" {{ E-sad }}</biw>"
            run 0 "noinfo" "apt-get install -f -y" && xecho "$info_prefix <biw>Tryed fixing dependency issues (if they exist.)"
            ;;
          Sh)
            xecho "$info_prefix <biw>Running installation script from \"$pkg_source\".</biw>"
            run 0 "noinfo" "curl -Ls \"$pkg_source\" | bash" && xecho "$good_prefix <biw>Installed \"$pkg\" successfully! {{ E-smile }}</biw>" || xecho "$error_prefix <biw>Could not install \"$pkg\" {{ E-sad }}</biw>"
            ;;
          *)
            xecho "$error_prefix <biw>Package type is invaild \"$pkg_type\", skipping. (Use Deb/Pkg/Sh)</biw>"
            ;;
        esac
      fi
    done
  fi
}

function rn_Run_Lines {
  parse_yaml 1 Run_Lines
  if [ "${#Run_Lines[@]}" -ne 0 ] && [ ! -z "${Run_Lines}" ]; then
    for rl_cmd in "${Run_Lines[@]}"; do
      run 0 "noinfo" "$rl_cmd" && xecho "$good_prefix <biw>Executed command: <on_b><bw>$rl_cmd</on_b></bw> <biw>successfully!</biw>." ||  xecho "$error_prefix <biw>Could not execute command: <on_b><bw>$rl_cmd</on_b></bw> {{ E-sad }}."
    done
  fi
}

function rn_Plugins {
  parse_yaml 2 Plugins name script
  if [ "${#Plugins[@]}" -ne 0 ]; then
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
}

function rn_Users {
  parse_yaml 3 Users name pass sudo
  if [ "${#Users[@]}" -ne 0 ]; then
    U_keys=($(tr ' ' '\n' <<< "${!Users[@]}" | grep -Ev '\[(0|1)\]' | sort -u))
    for user in "${U_keys[@]}"; do
      userpass="${Users["$user [0]"]}"
      usersudo="${Users["$user [1]"]}"
      test "$userpass" == "%Gen%" && userpass="$(gen_random all)"
      xecho "$info_prefix <biw>Creating user \"$user\" (sudo? $usersudo).</biw>"
      if [ $(cat /etc/passwd | grep "$user:" &> /dev/null;echo $?) -ne 0 ]; then
        run 0 "noinfo" "useradd \"$user\"" && xecho "$good_prefix <biw>Added user \"$user\".</biw>" || xecho "$error_prefix <biw>Could not add user \"$user\".</biw>"
        test "$### Usersusersudo" == "yes" && run 0 "noinfo" "usermod -aG sudo \"$user\""
        run 0 "noinfo" "echo -e \"$userpass\n$userpass\" | passwd $user"
      else
      xecho "$notgood_prefix <biw>User exists alredy {{ E-angry }} {{ BR-scissors }} skipping.</biw>"
      fi
    done
  fi
}

# Main
xecho "$banner"

## Check if the script is run as root
test "$UID" -ne 0 && fail 1 "Script must be run as root, exiting."

## Check dependencies
check_dependencies "yq" "$notgood_prefix <biw>Dependency missing, trying to install yq.</biw>" "curl -Lso '/usr/bin/yq' 'https://github.com/mikefarah/yq/releases/download/v4.44.2/yq_linux_amd64' && chmod +x /usr/bin/yq" "which yq"

## Get conf file
conf_file="$1"
test -z "$conf_file" && user_input conf_file "txt" "$info_prefix <biw>What configuration file would you like to use? : </biw>"
test -e "$conf_file" && configuration="$(cat $conf_file)" || fail 1 "Configuration file \"$conf_file\" not found, exiting."
yq_err="$(yq e . "$conf_file" 2>&1 > /dev/null)"
test -z "$yq_err" || fail 1 "Configuration fail is invaild: <on_b><bir>$yq_err</bir></on_b>"
keys=($(yq 'keys | .[]' <<< "$configuration" 2> /dev/null))

# parse_yaml 2 Environment_Configuration content

## Refresh package index
xecho "$info_prefix <biw>Refreshing local package index. {{ E-redo }}</biw>"
run 0 "noinfo" "apt-get update"

## Execute functions
for key in "${keys[@]}"
do
  rn_$key
done

xecho "$info_prefix <biw>Done. {{ E-smile }}</biw>"
