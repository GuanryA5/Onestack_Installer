#!/bin/bash 
set -e

################################参数区#############################
LinuxVersion=$(for temp in `cat /etc/system-release`;do echo $temp|sed -n '/^[0-9]/p';done)
baseshell=$(cd `dirname $0`; pwd)
basepath=$(cd $baseshell;cd packages; pwd)
scripts="$(cd $baseshell; pwd)/conf"

ZBBackage="zabbix-3.2.7.tar.gz"
ZBBackageName=$(echo $ZBBackage|awk -F ".tar" '{print $1}')
BASEDIR="/usr/local/zabbix"

Agent_Server="192.168.1.1"
Agent_ServerActive="192.168.1.1"

Agent_Hostname="$(hostname)"
Agent_Timeout="30"
CONF_FILE="${BASEDIR}/etc/zabbix_agentd.conf"
PidFile="${BASEDIR}/logs/zabbix_agentd.pid"
LogFile="${BASEDIR}/logs/zabbix_agentd.log"
Agent_ListenPort="10050"
#Include="/usr/local/zabbix/etc/zabbix_agentd.conf.d/*.conf"
Agent_UnsafeUserParameters="1"
Agent_EnableRemoteCommands="1"
Agent_LogRemoteCommands="0"
Agent_StartAgents="10"
Agent_LogFileSize="100"
Agent_HostMetadataItem="system.uname"

DEBUG_COMMANDS="1" #开启调试

#############################命令执行#############################
function run() {
    _cmd="${1}"
    _debug="0"

    _red="\033[0;31m"
    _green="\033[0;32m"
    _reset="\033[0m"
    _user="$(whoami)"

    # 如果设置了第二个参数，可以开启调试模式
    if [ "${#}" = "2" ];then
        if [ "${2}" = "1" ];then
            _debug="1"
        fi
    fi

    if [ "${DEBUG_COMMANDS}" = "1" ] || [ "${_debug}" = "1" ];then
        printf "${_red}%s \$ ${_green}${_cmd}${_reset}\n" "${_user}"
    fi
    sh -c "LANG=C LC_ALL=C ${_cmd}"
}

##############################环境包########################################
function Env(){
    run "rpm -Uvh --force --nodeps --replacepkgs ${basepath}/*.rpm"
}

####################################区域分割线###################################
function parting(){
    local string
    if [ "$#" = 0 ];then
        echo -e "\033[34;1m" && printf "%40s" '='|tr ' ' '=' && echo -e "\033[31m[null]\c" && echo -e "\033[34m\c" && printf "%40s\n" '='|tr ' ' '=' && echo -e "\033[0m"
		sleep 3
    fi
    if [ "$#" -ge 1 ];then
        string=$*
        echo -e "\033[34;1m" && printf "%40s" '='|tr ' ' '=' && echo -e "\033[31m[$string]\c" && echo -e "\033[34m\c" && printf "%40s\n" '='|tr ' ' '=' && echo -e "\033[0m"
		sleep 3
    fi
}

###############################用户和组###################################
function user_group_check(){
    parting "用户和组检查"
    # Group  Add Check
    local group=`cat /etc/group |grep zabbix |awk -F':' '{print $1}'`
    if [ "$group" = "zabbix" ];then
        echo "zabbix Group YES"
    else
        run "groupadd zabbix"
        echo "zabbix Group Creat Success"
    fi

    # User Add Check 
    user=`cat /etc/passwd |grep zabbix |awk -F':' '{print $1}'`
    if [ "$user" = "zabbix" ];then
        echo "zabbix User YES"
    else
        run "useradd -g zabbix zabbix"
        echo "zabbix User Create Success"
    fi
}

#######################目录检查#################
function catalog_check(){
    if [ -d ${2} ];then
        echo -e "\033[31m ${1} 目录存在，路径:${2}\033[0m"
        catalog="ture"
    else
        echo -e "\033[32m ${1} 目录不存在，检测路径:${2}\033[0m"
        catalog="false"
    fi
}

#####################文件检查#################
function file_check(){
    if [ -f ${2} ];then
        echo -e "\033[31m ${1} 文件存在,路径:${2}\033[0m"
        file="ture"
    else
        echo -e "\033[32m ${1} 文件不存在,路径:${2}\033[0m"
        file="false"
    fi
}

###############################zabbix agent instal########################
function AgentInstall(){
	catalog_check "zabbix_agentd" "${BASEDIR}"
	file_check "zabbix_agentd" "/etc/init.d/zabbix_agentd"
	if [ ${catalog}x = "false"x ] && [ ${file}x = "false"x ];then
        parting "zabbix_agent_install"
        if [ ! -d ${basepath}/${ZBBackageName} ];then
            run "tar xf ${basepath}/${ZBBackage} -C ${basepath}"
        fi
    
        run "cd ${basepath}/${ZBBackageName};./configure --prefix=/usr/local/zabbix --enable-agent && echo succeed"
        run "cd ${basepath}/${ZBBackageName} && make && make install && echo succeed"
        sleep 1 

        run "cp ${basepath}/${ZBBackageName}/misc/init.d/fedora/core/zabbix_agentd /etc/init.d/"
        run "chmod u+x  /etc/init.d/zabbix_agentd"

        #创建存放脚本目录，放入监控磁盘IO的perl脚本
        run "mkdir -p ${BASEDIR}/scripts"
        run "cp ${scripts}/discover_disk.pl ${BASEDIR}/scripts/"
        run "chmod u+x ${BASEDIR}/scripts/discover_disk.pl"

        # Edit zabbix_agentd
        run "sed -i \"s@BASEDIR=/usr/local@BASEDIR=${BASEDIR}@g\" /etc/init.d/zabbix_agentd"
        run "sed -i \"s@PIDFILE=/tmp/\\\$BINARY_NAME.pid@PIDFILE=${BASEDIR}/logs/\\\$BINARY_NAME.pid@g\" /etc/init.d/zabbix_agentd"

        # Edit zabbix_agentd.conf
        run "sed -i \"s/Server=127.0.0.1/Server=${Agent_Server}/g\" `grep Server= -rl $CONF_FILE`"
        #下面这行只能运行一次
        run "sed -i \"s@Hostname=Zabbix server@Hostname=${Agent_Hostname}@g\" `grep Hostname= -rl ${CONF_FILE}`"
        run "sed -i \"s@LogFile=/tmp/zabbix_agentd.log@LogFile=${LogFile}@g\" `grep LogFile= -rl ${CONF_FILE}`"
        run "sed -i \"s@\# PidFile=/tmp/zabbix_agentd.pid@PidFile=$PidFile@g\" `grep PidFile= -rl ${CONF_FILE}`"
        run "sed -i \"s@\# ListenPort=10050@ListenPort=${Agent_ListenPort}@g\" `grep ListenPort= -rl ${CONF_FILE}`"
        run "sed -i \"s@\# Timeout=3@Timeout=${Agent_Timeout}@g\" `grep Timeout= -rl ${CONF_FILE}`"
        run "sed -i \"s@ServerActive=127.0.0.1@ServerActive=${Agent_ServerActive}@g\" `grep ServerActive= -rl ${CONF_FILE}`"
        #run "sed -i \"s@\# Include=/usr/local/etc/zabbix_agentd.conf.d/@Include=${Include}@g\" `grep Include= -rl ${CONF_FILE}`"
        run "sed -i \"s@\# EnableRemoteCommands=0@EnableRemoteCommands=${Agent_EnableRemoteCommands}@g\" `grep EnableRemoteCommands= -rl ${CONF_FILE}`"
        run "sed -i \"s@\# LogRemoteCommands=0@LogRemoteCommands=${Agent_LogRemoteCommands}@g\" `grep LogRemoteCommands= -rl ${CONF_FILE}`"
        run "sed -i \"s@\# UnsafeUserParameters=0@UnsafeUserParameters=${Agent_UnsafeUserParameters}@g\" `grep UnsafeUserParameters= -rl ${CONF_FILE}`"
        run "sed -i \"s@\# StartAgents=3@StartAgents=${Agent_StartAgents}@g\" `grep StartAgents= -rl ${CONF_FILE}`"
        run "sed -i \"s@\# LogFileSize=1@LogFileSize=${Agent_LogFileSize}@g\" `grep LogFileSize= -rl ${CONF_FILE}`"
        run "sed -i \"s@\# HostMetadataItem=@HostMetadataItem=${Agent_HostMetadataItem}@g\" `grep HostMetadataItem= -rl ${CONF_FILE}`"
        #监控磁盘IO的配置
        run "sed -i '\$aUserParameter=ping[*],ping \$1 -c \$2 > /dev/null && echo 1 || echo 0' ${CONF_FILE}"
        run "sed -i '\$aUserParameter=discovery.disks.iostats,/usr/local/zabbix/scripts/discover_disk.pl\nUserParameter=vfs.dev.read.sectors[*],cat /proc/diskstats | grep \$1 | head -1 | awk '\''{print \$\$6}'\''\nUserParameter=vfs.dev.write.sectors[*],cat /proc/diskstats | grep \$1 | head -1 | awk '\''{print \$\$10}'\''\nUserParameter=vfs.dev.read.ops[*],cat /proc/diskstats | grep \$1 | head -1 |awk '\''{print \$\$4}'\''\nUserParameter=vfs.dev.write.ops[*],cat /proc/diskstats | grep \$1 | head -1 | awk '\''{print \$\$8}'\''\nUserParameter=vfs.dev.read.ms[*],cat /proc/diskstats | grep \$1 | head -1 | awk '\''{print \$\$7}'\''\nUserParameter=vfs.dev.write.ms[*],cat /proc/diskstats | grep \$1 | head -1 | awk '\''{print \$\$11}'\''\nUserParameter=user_disk,/usr/local/zabbix/scripts/user_disk.sh' ${CONF_FILE}"

        if [ ! -d ${BASEDIR}/logs ];then
            mkdir ${BASEDIR}/logs
        fi
        run "chown -R zabbix.zabbix ${BASEDIR}/"
    fi
}

# Start Zabbix-agent on Boot
function agentd_boot(){
	parting "Start Zabbix-agent on Boot"
	if
		cat /etc/rc.local | grep "service zabbix_agentd start" > /dev/null 2>&1
		then
			echo "Start on boot Already Exists"
		elif
			cat /etc/rc.local | grep "exit 0" > /dev/null 2>&1
		then
            sed -i "s/exit 0/service zabbix_agentd start\nexit 0/g" /etc/rc.local
		else
            echo "service zabbix-agent start" >> /etc/rc.local
    fi
echo "Starting the Zabbix-Agent...."
run "service zabbix_agentd start && ss -tnlp"
}

# Check Zabbix agentd Starting Status
function agentd_status(){
    parting "agentd_status_check"
    local c=`netstat -apn |grep zabbix_agentd |grep -v grep |wc -l`
    #if [ $c -eq "1" ];then
    if [ $c -gt 0 ];then
        echo "Zabbix agentd Starting Success!"
    else
        echo "Zabbix agentd Starting ERROR!"
    fi
}

# Check Iptables Status
function iptables(){
	parting "Check Iptables Status"
	local sign
	if [ ${LinuxVersion:0:1}x = "6"x ];then
        run "mkfifo -m 777 /tmp/fifo"
        run "/etc/init.d/iptables status &> /dev/null && sign=\"ture\" || sign=\"false\";echo \"\$sign\" > /tmp/fifo &"
        read sign < /tmp/fifo
        run "rm /tmp/fifo"
		if [ ${sign}x = "ture"x ];then
			echo "iptables Runing!"
            if ! grep -q 10050 /etc/sysconfig/iptables;then
                run "sed -i '9a \-A INPUT \-m state \-\-state NEW \-m tcp \-p tcp \-\-dport '$Agent_ListenPort' \-j ACCEPT' /etc/sysconfig/iptables"
                run "sed -i '9a \-A OUTPUT \-m state \-\-state NEW \-m tcp \-p tcp \-\-dport '$Agent_ListenPort' \-j ACCEPT' /etc/sysconfig/iptables"
            fi
#			run "/etc/init.d/iptables restart"
			echo "Close iptables or To open up 10050 TCP port!"
		else
			echo "iptables NOT Runing"
		fi
	elif [ ${LinuxVersion:0:1}x = "7"x ];then
        run "mkfifo -m 777 /tmp/iptab || exit 0"
        run "firewall-cmd --state &> /dev/null && sign=\"ture\" || sign=\"false\";echo \"\$sign\" > /tmp/iptab &"
        read sign < /tmp/iptab
        run "rm /tmp/iptab"
		if [ ${sign}x = "ture"x ];then
			run "firewall-cmd --permanent --add-port=$Agent_ListenPort/tcp"
#			run "firewall-cmd --reload"
		else
			echo "firewall not runing"
		fi
	fi
}

case $1 in
    *)
        Env;
        user_group_check;
        AgentInstall;
		agentd_boot;
        agentd_status;
        iptables;
    ;;
    *)
 #       echo -e "usage: `basename ${0}` [install]"
esac
exit 0
