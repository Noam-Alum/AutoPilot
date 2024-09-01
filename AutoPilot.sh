#!/bin/bash
# 
# **AutoPilot - It's simple.**
#
# | Author: Noam Alum
# | Created: July 30, 2024
# | Last modified: Thu Aug 15, 2024
# | Version: 1.0
# | Description: This script automates the setup of a new system with essential configurations.
#

source <(curl -Ls "https://raw.githubusercontent.com/Noam-Alum/utils.sh/main/utils-min.sh")

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
function fail {
  xecho "$error_prefix <biw>$2</biw> <bir>{{ E-fail }}</bir>"
  exit $1 
}
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

## Environment_configuration
function rn_Environment_configuration {
  parse_yaml 2 Environment_configuration user config
  if [ "${#Environment_configuration[@]}" -ne 0 ]; then
    for env_user in ${!Environment_configuration[@]}
    do
      xecho "$info_prefix <biw>Trying to add environment configuration to user \"$env_user\".</biw>"
      if [ $(cat /etc/passwd | grep "$env_user:" &> /dev/null;echo $?) -eq 0 ]; then
        test -d "$(grep "$env_user:" /etc/passwd | awk -F: '{print $(NF-1)}')" || run 0 'noinfo' "mkdir -p /home/$env_user/"
        printf -v env_config '%q' "${Environment_configuration[$env_user]}"
        run 0 'noinfo' 'eval echo $env_config >> /home/$env_user/.bashrc' && xecho "$good_prefix <biw>Added environment configuration successfully.</biw><big>{{ E-success }}</big>" || xecho "$error_prefix <biw>Failed to add environment configuration. {{ E-nervous }}</biw>"
      else
        xecho "$notgood_prefix <biw>User does not exist! could not add environment configuration. {{ E-angry }}</biw>"
      fi
    done
  fi
}
function rn_el_Environment_configuration {
  parse_yaml 2 Environment_configuration user config
  if [ "${#Environment_configuration[@]}" -ne 0 ]; then
    for env_user in ${!Environment_configuration[@]}
    do
      xecho "$info_prefix <biw>Trying to add environment configuration to user \"$env_user\".</biw>"
      if [ $(cat /etc/passwd | grep "$env_user:" &> /dev/null;echo $?) -eq 0 ]; then
        test -d "$(grep "$env_user:" /etc/passwd | awk -F: '{print $(NF-1)}')" || run 0 'noinfo' "mkdir -p /home/$env_user/"
        printf -v env_config '%q' "${Environment_configuration[$env_user]}"
        run 0 'noinfo' 'eval echo $env_config >> /home/$env_user/.bashrc' && xecho "$good_prefix <biw>Added environment configuration successfully.</biw><big>{{ E-success }}</big>" || xecho "$error_prefix <biw>Failed to add environment configuration. {{ E-nervous }}</biw>"
      else
        xecho "$notgood_prefix <biw>User does not exist! could not add environment configuration. {{ E-angry }}</biw>"
      fi
    done
  fi
}

## Cronjobs
function rn_Cronjobs {
  parse_yaml 2 Cronjobs user rules
  if [ "${#Cronjobs[@]}" -ne 0 ]; then
    for c_user in ${!Cronjobs[@]}
    do
      xecho "$info_prefix <biw>Trying to add cronjob rules to user \"$c_user\".</biw>"
      if [ $(cat /etc/passwd | grep "$c_user:" &> /dev/null;echo $?) -eq 0 ]; then
        c_rules_file="/tmp/$c_user-cron-$(gen_random str)-tmp"
        printf -v c_rules '%q' "${Cronjobs[$c_user]}"
        crontab -u noam -l > $c_rules_file 2> /dev/null
        run 0 'noinfo' 'eval echo "$c_rules" >> $c_rules_file'
        run 0 'noinfo' 'eval crontab -u "$c_user" "$c_rules_file"' && xecho "$good_prefix <biw>Added cronjob rules successfully.</biw><big>{{ E-success }}</big>" || xecho "$error_prefix <biw>Failed to add cronjob rules. {{ E-nervous }}</biw>"
        run 0 'noinfo' 'rm -rf $c_rules_file'
      else
        xecho "$notgood_prefix <biw>User does not exist! could not add cronjob rules. {{ E-angry }}</biw>"
      fi
    done
  fi
}
function rn_el_Cronjobs {
  parse_yaml 2 Cronjobs user rules
  if [ "${#Cronjobs[@]}" -ne 0 ]; then
    for c_user in ${!Cronjobs[@]}
    do
      xecho "$info_prefix <biw>Trying to add cronjob rules to user \"$c_user\".</biw>"
      if [ $(cat /etc/passwd | grep "$c_user:" &> /dev/null;echo $?) -eq 0 ]; then
        c_rules_file="/tmp/$c_user-cron-$(gen_random str)-tmp"
        printf -v c_rules '%q' "${Cronjobs[$c_user]}"
        crontab -u noam -l > $c_rules_file 2> /dev/null
        run 0 'noinfo' 'eval echo "$c_rules" >> $c_rules_file'
        run 0 'noinfo' 'eval crontab -u "$c_user" "$c_rules_file"' && xecho "$good_prefix <biw>Added cronjob rules successfully.</biw><big>{{ E-success }}</big>" || xecho "$error_prefix <biw>Failed to add cronjob rules. {{ E-nervous }}</biw>"
        run 0 'noinfo' 'rm -rf $c_rules_file'
      else
        xecho "$notgood_prefix <biw>User does not exist! could not add cronjob rules. {{ E-angry }}</biw>"
      fi
    done
  fi
}

## Network_Configuration
function rn_Network_Configuration {
  parse_yaml 4 Network_Configuration nic ip gateway dns
  check_dependencies "NetworkManager" "$notgood_prefix <biw>Dependency missing, trying to install NetworkManager.</biw>" "apt install -yq NetworkManager &> /dev/null" "which nmcli"

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
function rn_el_Network_Configuration {
  parse_yaml 4 Network_Configuration nic ip gateway dns
  check_dependencies "NetworkManager" "$notgood_prefix <biw>Dependency missing, trying to install NetworkManager.</biw>" "dnf install -y NetworkManager &> /dev/null" "which nmcli"

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

## SELinux
function rn_SELinux {
  parse_yaml 0 SELinux
  if [ "$SELinux" == "Enabled" ]; then
    xecho "$info_prefix <biw>Trying to enable {{ E-arrowright }} SELinux {{ E-arrowleft }} {{ E-nervous }}</biw>"
    check_dependencies "SELinux" "$notgood_prefix <biw>SELinux not found, trying to install, be patient. {{ E-angry }}</biw>" "apt -y install selinux-basics selinux-policy-default" "dpkg -L selinux-basics"
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
function rn_el_SELinux {
  parse_yaml 0 SELinux
  if [ "$SELinux" == "Enabled" ]; then
    xecho "$info_prefix <biw>Trying to enable {{ E-arrowright }} SELinux {{ E-arrowleft }} {{ E-nervous }}</biw>"
    check_dependencies "SELinux" "$notgood_prefix <biw>SELinux not found, trying to install, be patient. {{ E-angry }}</biw>" "dnf install -y selinux-policy selinux-policy-targeted policycoreutils" "dnf list installed selinux-policy"
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

## Installed_packages
function rn_Installed_packages {
  parse_yaml 3 Installed_packages name type source
  if [ "${#Installed_packages[@]}" -ne 0 ]; then
    Pm="$(test "$Running_OS" == "Debian" && echo "apt" || echo "dnf")"
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
          Pm)
            xecho "$info_prefix <biw>Using $Pm to install \"$pkg\", be patient.</biw>" 
            run 0 "noinfo" "$Pm -y install $pkg_source" && xecho "$good_prefix <biw>Installed \"$pkg\" successfully! {{ E-smile }}</biw>" || xecho "$error_prefix <biw>Could not install \"$pkg\" {{ E-sad }}</biw>"
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
            xecho "$error_prefix <biw>Package type is invaild \"$pkg_type\", skipping. (Use Pm/Pkg/Sh)</biw>"
            ;;
        esac
      fi
    done
  fi
}
function rn_el_Installed_packages {
  parse_yaml 3 Installed_packages name type source
  if [ "${#Installed_packages[@]}" -ne 0 ]; then
    Pm="$(test "$Running_OS" == "Debian" && echo "apt" || echo "dnf")"
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
          Pm)
            xecho "$info_prefix <biw>Using $Pm to install \"$pkg\", be patient.</biw>" 
            run 0 "noinfo" "$Pm -y install $pkg_source" && xecho "$good_prefix <biw>Installed \"$pkg\" successfully! {{ E-smile }}</biw>" || xecho "$error_prefix <biw>Could not install \"$pkg\" {{ E-sad }}</biw>"
            ;;
          Pkg)
            xecho "$info_prefix <biw>Fetching package from \"$pkg_source\".</biw>"
            ia_deb_package_name="$(gen_random str)_$pkg.rpm"
            run 0 "noinfo" "curl -sLo /tmp/$ia_deb_package_name \"$pkg_source\" && dnf install -y /tmp/$ia_deb_package_name" && xecho "$good_prefix <biw>Installed \"$pkg\" successfully! {{ E-smile }}</biw>" || xecho "$error_prefix <biw>Could not install \"$pkg\" {{ E-sad }}</biw>"
            ;;
          Sh)
            xecho "$info_prefix <biw>Running installation script from \"$pkg_source\".</biw>"
            run 0 "noinfo" "curl -Ls \"$pkg_source\" | bash" && xecho "$good_prefix <biw>Installed \"$pkg\" successfully! {{ E-smile }}</biw>" || xecho "$error_prefix <biw>Could not install \"$pkg\" {{ E-sad }}</biw>"
            ;;
          *)
            xecho "$error_prefix <biw>Package type is invaild \"$pkg_type\", skipping. (Use Pm/Pkg/Sh)</biw>"
            ;;
        esac
      fi
    done
  fi
}

## Run_Lines
function rn_Run_Lines {
  parse_yaml 1 Run_Lines
  if [ "${#Run_Lines[@]}" -ne 0 ] && [ ! -z "${Run_Lines}" ]; then
    for rl_cmd in "${Run_Lines[@]}"; do
      run 0 "noinfo" "$rl_cmd" && xecho "$good_prefix <biw>Executed command: <on_b><bw>$rl_cmd</on_b></bw> <biw>successfully!</biw>." ||  xecho "$error_prefix <biw>Could not execute command: <on_b><bw>$rl_cmd</on_b></bw> {{ E-sad }}."
    done
  fi
}
function rn_el_Run_Lines {
  parse_yaml 1 Run_Lines
  if [ "${#Run_Lines[@]}" -ne 0 ] && [ ! -z "${Run_Lines}" ]; then
    for rl_cmd in "${Run_Lines[@]}"; do
      run 0 "noinfo" "$rl_cmd" && xecho "$good_prefix <biw>Executed command: <on_b><bw>$rl_cmd</on_b></bw> <biw>successfully!</biw>." ||  xecho "$error_prefix <biw>Could not execute command: <on_b><bw>$rl_cmd</on_b></bw> {{ E-sad }}."
    done
  fi
}

## Plugins
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
function rn_el_Plugins {
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

## Users
function rn_Users {
  parse_yaml 4 Users name pass group shell
  if [ "${#Users[@]}" -ne 0 ]; then
    U_keys=($(tr ' ' '\n' <<< "${!Users[@]}" | grep -Ev '\[(0|1|2)\]' | sort -u))
    for user in "${U_keys[@]}"; do
      userpass="${Users["$user [0]"]}"
      usergrp="${Users["$user [1]"]}"
      usershell="${Users["$user [2]"]}"
      test "$userpass" == "%Gen%" && userpass="$(printf '%q' "$(gen_random all)")"
      xecho "$info_prefix <biw>Creating user \"$user\".</biw>"
      if [ $(cat /etc/passwd | grep "$user:" &> /dev/null;echo $?) -ne 0 ]; then

        run 0 "noinfo" "useradd \"$user\"" && xecho "$good_prefix <biw>Added user \"$user\".</biw>" || xecho "$error_prefix <biw>Could not add user \"$user\".</biw>"

        for u_grp in $(tr -s ',' ' ' <<< "$usergrp")
        do
          getent group $u_grp &> /dev/null && run 0 "noinfo" "usermod -aG $u_grp \"$user\"" && xecho "$good_prefix <biw>Added user \"$user\" to group named \"$u_grp\" successfully.</biw>" || xecho "$notgood_prefix <biw>Could not added user \"$user\" to group named \"$u_grp\".</biw>"
        done

        cat /etc/shells | grep -w "$usershell" &> /dev/null && run 0 "noinfo" "usermod --shell $usershell $user" && xecho "$good_prefix <biw>Changed user \"$user\" shell to $usershell</biw>" || xecho "$notgood_prefix <biw>Could not change user \"$user\" shell to $usershell {{ E-sad }}</biw>"

        run 0 "noinfo" "echo -e \"$userpass\n$userpass\" | passwd $user"
        test -d "$(grep "$user:" /etc/passwd | awk -F: '{print $(NF-1)}')" || run 0 'noinfo' "mkdir -p /home/$user/"
        run 0 "noinfo" "echo \"$userpass\" > /home/$user/.password" && xecho "$info_prefix <biw>Password for user \"$user\" has been stored at \"/home/$user/.password\", please copy it and store it in a safe place {{ E-music }}, then</biw> <bir>DELETE IT {{ E-angry }}</bir><biw>.</biw>"
        run 0 "noinfo" "chown $user.$user /home/$user/.password"
        run 0 "noinfo" "chmod 600 /home/$user/.password"
      else
      xecho "$notgood_prefix <biw>User exists alredy {{ E-angry }} {{ BR-scissors }} skipping.</biw>"
      fi
    done
  fi
}
function rn_el_Users {
  parse_yaml 4 Users name pass group shell
  if [ "${#Users[@]}" -ne 0 ]; then
    U_keys=($(tr ' ' '\n' <<< "${!Users[@]}" | grep -Ev '\[(0|1|2)\]' | sort -u))
    for user in "${U_keys[@]}"; do
      userpass="${Users["$user [0]"]}"
      usergrp="${Users["$user [1]"]}"
      usershell="${Users["$user [2]"]}"
      test "$userpass" == "%Gen%" && userpass="$(printf '%q' "$(gen_random all)")"
      xecho "$info_prefix <biw>Creating user \"$user\".</biw>"
      if [ $(cat /etc/passwd | grep "$user:" &> /dev/null;echo $?) -ne 0 ]; then

        run 0 "noinfo" "useradd \"$user\"" && xecho "$good_prefix <biw>Added user \"$user\".</biw>" || xecho "$error_prefix <biw>Could not add user \"$user\".</biw>"

        for u_grp in $(tr -s ',' ' ' <<< "$usergrp")
        do
          getent group $u_grp &> /dev/null && run 0 "noinfo" "usermod -aG $u_grp \"$user\"" && xecho "$good_prefix <biw>Added user \"$user\" to group named \"$u_grp\" successfully.</biw>" || xecho "$notgood_prefix <biw>Could not added user \"$user\" to group named \"$u_grp\".</biw>"
        done

        cat /etc/shells | grep -w "$usershell" &> /dev/null && run 0 "noinfo" "usermod --shell $usershell $user" && xecho "$good_prefix <biw>Changed user \"$user\" shell to $usershell</biw>" || xecho "$notgood_prefix <biw>Could not change user \"$user\" shell to $usershell {{ E-sad }}</biw>"

        run 0 "noinfo" "echo -e \"$userpass\n$userpass\" | passwd $user"
        test -d "$(grep "$user:" /etc/passwd | awk -F: '{print $(NF-1)}')" || run 0 'noinfo' "mkdir -p /home/$user/"
        run 0 "noinfo" "echo \"$userpass\" > /home/$user/.password" && xecho "$info_prefix <biw>Password for user \"$user\" has been stored at \"/home/$user/.password\", please copy it and store it in a safe place {{ E-music }}, then</biw> <bir>DELETE IT {{ E-angry }}</bir><biw>.</biw>"
        run 0 "noinfo" "chown $user.$user /home/$user/.password"
        run 0 "noinfo" "chmod 600 /home/$user/.password"
      else
      xecho "$notgood_prefix <biw>User exists alredy {{ E-angry }} {{ BR-scissors }} skipping.</biw>"
      fi
    done
  fi
}

## Repo
function rn_Repo {
  parse_yaml 3 Repo name configuration key
  if [ "${#Repo[@]}" -ne 0 ]; then
    REPO_keys=($(tr ' ' '\n' <<< "${!Repo[@]}" | grep -Ev '\[(0|1)\]' | sort -u))
    for repo in "${REPO_keys[@]}"
    do
      repo_config="${Repo["$repo [0]"]}"
      repo_key="${Repo["$repo [1]"]}"
      xecho "$info_prefix <biw>Trying to add repo named {{ E-gun }} \"$repo\" to sources list.</biw>"
      test -d '/etc/apt/sources.list.d/' ||\
        xecho "$error_prefix <biw>Directory</biw> <on_b><biw>/etc/apt/sources.list.d/</biw></on_b> <biw>does not exists, cant add repo. {{ E-sad }}</biw>" &&\
        run 0 'noinfo' "echo \"$repo_config\" > /etc/apt/sources.list.d/$repo.list" &&\
        xecho "$good_prefix <biw>Added repo to sources list at</biw> <on_b><biw>/etc/apt/sources.list.d/$repo.list</biw></on_b> <biw>successfully!</biw>" ||\
        xecho "$notgood_prefix <biw>Could not add repo to sources list. {{ E-sad }}</biw>"
      if [ "$repo_key" != "%NoKey%" ]; then
        test -d '/etc/apt/trusted.gpg.d/' ||\
          xecho "$error_prefix <biw>Directory</biw> <on_b><biw>/etc/apt/trusted.gpg.d/</biw></on_b> <biw>does not exists, cant add repo. {{ E-sad }}</biw>" &&\
          run 0 'noinfo' "curl -s $repo_key 2> /dev/null | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/$repo.gpg" &&\
          xecho "$good_prefix <biw>Added gpg key successfully!</biw>" ||\
          xecho "$notgood_prefix <biw>Could not add gpg key.</biw>"
      fi
    done
    xecho "$info_prefix <biw>Updating the local package index. {{ E-redo }}</biw>"
    run 0 'noinfo' 'apt-get update'
  fi
}
function rn_el_Repo {
  parse_yaml 3 Repo name configuration key
  if [ "${#Repo[@]}" -ne 0 ]; then
    REPO_keys=($(tr ' ' '\n' <<< "${!Repo[@]}" | grep -Ev '\[(0|1)\]' | sort -u))
    for repo in "${REPO_keys[@]}"
    do
      repo_config="${Repo["$repo [0]"]}"
      repo_key="${Repo["$repo [1]"]}"
      xecho "$info_prefix <biw>Trying to add repo named {{ E-gun }} \"$repo\" to list of repositories.</biw>"
        if [ ! -d '/etc/yum.repos.d/' ]; then
          xecho "$error_prefix <biw>Directory</biw> <on_b><biw>/etc/yum.repos.d/</biw></on_b> <biw>does not exists, cant add repo. {{ E-sad }}</biw>"
        else
          run 0 'noinfo' "echo \"$repo_config\" > /etc/yum.repos.d/$repo.repo" &&\
          xecho "$good_prefix <biw>Added repo to list of repositories at</biw> <on_b><biw>/etc/yum.repos.d/$repo.repo</biw></on_b> <biw>successfully!</biw>" ||\
          xecho "$notgood_prefix <biw>Could not add repo to list of repositories. {{ E-sad }}</biw>"
        fi
      if [ "$repo_key" != "%NoKey%" ]; then
        xecho "$info_prefix <biw>Exporting key to</biw> <on_b><biw>/etc/pki/rpm-gpg/</biw></on_b><biw>.</biw>"
        if [ ! -d '/etc/pki/rpm-gpg/' ]; then
          xecho "$error_prefix <biw>Directory</biw> <on_b><biw>/etc/pki/rpm-gpg/</biw></on_b> <biw>does not exists, cant add repo. {{ E-sad }}</biw>"
        else
          run 0 'noinfo' "curl -s $repo_key 2> /dev/null | sudo gpg --dearmor --yes -o /etc/pki/rpm-gpg/$repo.gpg" &&\
          xecho "$good_prefix <biw>Added gpg key successfully!</biw>" ||\
          xecho "$notgood_prefix <biw>Could not add gpg key.</biw>"
        fi
      fi
    done
    xecho "$info_prefix <biw>Updating the local package index. {{ E-redo }}</biw>"
    run 0 "noinfo" "dnf clean all;dnf makecache"
  fi
}

## Time
function rn_Time {
  parse_yaml 0 Time
  xecho "$info_prefix <biw>Trying to change time zone to \"$Time\".</biw>"
  if [ "$(timedatectl list-timezones | grep -w "$Time" &> /dev/null;echo $?)" -eq 0 ]; then
    run 0 'noinfo' "timedatectl set-timezone $Time" && xecho "$good_prefix <biw>Changed time to $Time.</biw>" || xecho "$notgood_prefix <biw>Could not change time to $Time.</biw>"
  else
    xecho "$error_prefix <biw>Time zone \"$Time\" does not exist.</biw> <bir>{{ E-angry }}</bir>"
  fi
}
function rn_el_Time {
  parse_yaml 0 Time
  xecho "$info_prefix <biw>Trying to change time zone to \"$Time\".</biw>"
  if [ "$(timedatectl list-timezones | grep -w "$Time" &> /dev/null;echo $?)" -eq 0 ]; then
    run 0 'noinfo' "timedatectl set-timezone $Time" && xecho "$good_prefix <biw>Changed time to $Time.</biw>" || xecho "$notgood_prefix <biw>Could not change time to $Time.</biw>"
  else
    xecho "$error_prefix <biw>Time zone \"$Time\" does not exist.</biw> <bir>{{ E-angry }}</bir>"
  fi
}

# Main
xecho "$banner"

## Check if the script is run as root
test "$UID" -ne 0 && fail 1 "Script must be run as root, exiting."

## Check dependencies
check_dependencies "yq" "$notgood_prefix <biw>Dependency missing, trying to install yq.</biw>" "curl -Ls -o '/usr/bin/yq' 'https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64' && chmod +x /usr/bin/yq" "which yq"

## Get conf file
conf_file="$1"
test -z "$conf_file" && user_input conf_file "txt" "$info_prefix <biw>What configuration file would you like to use? : </biw>"
test -e "$conf_file" && configuration="$(cat $conf_file 2> /dev/null)" || fail 1 "Configuration file \"$conf_file\" not found, exiting."
yq_err="$(yq e . "$conf_file" 2>&1 > /dev/null)"
test -z "$yq_err" || fail 1 "Configuration fail is invaild: <on_b><bir>$yq_err</bir></on_b>"
keys=($(yq 'keys | .[]' <<< "$configuration" 2> /dev/null))

## Check Debian/RHEL related
parse_yaml 0 Running_OS
if [ "$Running_OS" == "null" ]; then
  if [ -e '/etc/os-release' ]; then
    Id_like_v="$(awk -F= '/^ID_LIKE=/ {gsub(/"/, "", $2); print $2}' /etc/os-release | tr -s ' ' '|')"
    [[ "rhel" =~ ^($Id_like_v)$ ]] && Running_OS="RHEL" || Running_OS="Debian"
  else
    fail 1 "Cant determine distro relation (RHEL/Debian), to continue add \"Running_OS: RHEL/Debian\" to your configuration file."
  fi
fi

## Refresh package index
xecho "$info_prefix <biw>Refreshing local package index. {{ E-redo }}</biw>"
if [ "$Running_OS" == "Debian" ]; then
  run 0 "noinfo" "apt-get update"
else
  run 0 "noinfo" "dnf clean all;dnf makecache"
fi

## Execute functions
for key in "${keys[@]}"
do
  if [[ ! "$key" =~ ^("Running_OS")$ ]]; then
    if [ "$Running_OS" == "Debian" ]; then
      rn_$key
    else
      rn_el_$key
    fi
  fi
done

xecho "$good_prefix <biw>Done. {{ E-smile }}</biw>"