#!/bin/bash
set -e

export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin
clear

printf "
#######################################
#     ZABBIX Installer ALL IN ONE     #
#                                     #
#######################################
"
# Check if user is root
[ $(id -u) != "0"] && echo "You must be root to run this scripts"; exit 1

zbxinstaller_dir=$(dirname "`readlink -f 0`")
pushd ${zbxinstaller_dir} > /dev/null
. ./version.txt
. ./options.conf
. ./include/color.sh
. ./include/check_os.sh
. ./include/initCentOS.sh

# check Monitor agent
while :; do echo
  read -e -p "Do you want to install Monitor? [y/n]" flag
  if [[ ! {$flag} =~ ^[y,n]$ ]];then
    echo "${CWARNING} input error! Please only input 'y' or 'n' ${CEND}"
  else
    if [ "${flag}" == 'y' ]; then
      while :; do echo
        echo 'Please select what you want install（选择部署 ZABBIX [Server/Agent]):'
        echo -e "\t${CMSG}0${CEND}. Do not install"
        echo -e "\t${CMSG}1${CEND}. Install Zabbix Server"
        echo -e "\t${CMSG}2${CEND}. Install Zabbix Agent"
        read -e -p "Please input a number:(Default 2 press Enter)" setup_option
        setup_option=${setup_option:-2}
        if [[ ! ${setup_option} =~ ^[0-2]$ ]]; then
          echo "${CWARNING}input error! Please only input number 0~2${CEND}"
        else
          [ "${setup_option}" != '0' -a -e "${zabbix_install_dir}/sbin/zabbix_server" ] && { echo "${CWARNING}Zabbix Server already installed!${CEND}"; unset setup_option }
          [ "${setup_option}" != '0' -a -e "${zabbix_install_dir}/sbin/zabbix_agent" ] && { echo "${CWARNING}Zabbix Agent already installed!${CEND}"; unset setup_option }
          break
        fi
      done
      if [ "${setup_option}" = 1 ]; then
        while :;do echo
          echo "[ZABBIX_SERVER], Please select a version(选择Server版本):"
          echo -e "\t${CMSG}1${CEND}. Install ZABBIX_SERVER-3.2"
          echo -e "\t${CMSG}2${CEND}. Install ZABBIX_SERVER-3.4"
          echo -e "\t${CMSG}3${CEND}. Install ZABBIX_SERVER-4.0"
          read -e -p "Please input a number:(Default '1' press Enter)" server_option
          server_option=${server_option:-1}
          if [[ ! ${server_option} =~ ^[1-3]$ ]]; then
            echo; echo "${CWARNING}input error! Please only input number 1-3${CEND}"; echo
            continue
          else
            break
          fi
        done
      elif [ "${setup_option}" = 2 ]; then
        while :;do echo
          echo "[ZABBIX_AGENT], Please select a version(选择Agent版本)"
          echo -e "\t${CMSG}1${CEND}. Install ZABBIX_AGENT-3.2"
          echo -e "\t${CMSG}2${CEND}. Install ZABBIX_AGENT-3.4"
          echo -e "\t${CMSG}3${CEND}. Install ZABBIX_AGENT-4.0"
          read -e -p "Please input a number:(Default '1' press Enter)" agent_option
          if [[ ! ${agent_option} =~ ^[1-3]$ ]]; then
            echo; echo "${CWARNING}input error! Please only input number 1-3${CEND}"; echo
            continue
          else
            break
          fi
        done
      fi
    fi
    break
  fi
done

# 选择监控对象
while :; do echo
  echo "Please select Applications Monitoring (选择需要监控的对象):"
  echo -e "\t${CMSG}0${CEND}. Do not install"
  echo -e "\t${CMSG}1${CEND}. [Apache]"
  echo -e "\t${CMSG}2${CEND}. [Ngnix]"
  echo -e "\t${CMSG}3${CEND}. [Tomcat]"
  echo -e "\t${CMSG}4${CEND}. [Java]"
  echo -e "\t${CMSG}5${CEND}. [Mysql]"
  echo -e "\t${CMSG}6${CEND}. [Oracle]"
  echo -e "\t${CMSG}7${CEND}. [Redis]"
  echo -e "\t${CMSG}8${CEND}. [Memcache]"
  read -e -p "Please input a number:(Default '3 5' press Enter)" monitor_option
  monitor_option=${monitor_option:-'3 5'}
  [ "${monitor_option}" = '0' ] && break
  array_monitor=(${monitor_option})
  array_all=(1 2 3 4 5 6 7 8)
    for v in ${array_option[@]}
    do
      [ -z "`echo ${array_all[@]} | grep -w ${v}`" ] && monitor_flag=1
    done
    if [ "${monitor_flag}" = '1']; then
      unset monitor_flag
      echo; echo "${CWARNING}input error! Please only input number 3 5 and so on${CEND}"; echo
      continue
    else
        [ -n "`echo ${array_monitor[@]} | grep -w 1`" ] && monitor_apache = 1
        [ -n "`echo ${array_monitor[@]} | grep -w 2`" ] && monitor_nginx = 1
        [ -n "`echo ${array_monitor[@]} | grep -w 3`" ] && monitor_tomcat = 1
        [ -n "`echo ${array_monitor[@]} | grep -w 4`" ] && monitor_java = 1
        [ -n "`echo ${array_monitor[@]} | grep -w 5`" ] && monitor_mysql = 1
        [ -n "`echo ${array_monitor[@]} | grep -w 6`" ] && monitor_oracle = 1
        [ -n "`echo ${array_monitor[@]} | grep -w 7`" ] && monitor_redis = 1
        [ -n "`echo ${array_monitor[@]} | grep -w 8`" ] && monitor_memcache = 1
      break
    fi
done

# check os information and configuare yum manage
. ./include/check_os.sh

# install wget gcc curl python
# [ "${PM}" == 'apt-get'] && apt-get -y update
[ "${PM}" == 'yum'] && yum clean all
${PM} -y install gcc gcc-c++ net-tools python

# get IP
IPADDR=$(./include/get_ipaddr)

startTime=`date +%s`

# 部署监控 SERVER/AGENT
if [ "${setup_option}" = '1' ]; then
  . include/zabbix_server.sh
  Install_Zabbix_server 2>&1 | tee -a ${zabbix_install_dir}/install.log
elif [ "${setup_option}" = '2' ]; then
  . include/zabbix_agent.sh
  Install_Zabbix_agent 2&>1 | tee -a ${zabbix_install_dir}/install.log
fi

# Apache
clear; echo "${CWARNING}[Monitor:-Apache] Start Installing ..."; echo
CHECK=$(curl -s http://localhost/server-status | sed -n '/Server uptime/p' | awk '{print $3 $5}')
if [ "$monitor_apache" == '1' -a "$CHECK" != "0" ] ; then
  . include/apache.sh
  Install_Zabbix_agent32 2&>1 | tee -a ${zabbix_install}
else
  echo; echo "${CWARNING}[Monitor:-Apache] Please check configuare, turn on the server status option! ${CEND}"; echo
  kill -9 $$
fi

#Nginx

    