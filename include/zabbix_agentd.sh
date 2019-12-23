#!/bin/bash 


##############################环境包########################################
Env(){
    run "yum -y install gcc gcc-c++ net-tools"
}

####################################区域分割线###################################
parting(){
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
user_group_check(){
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

catalog_check(){
    if [ -d ${2} ];then
        echo -e "\033[31m ${1} 目录存在，路径:${2}\033[0m"
        catalog="ture"
    else
        echo -e "\033[32m ${1} 目录不存在，检测路径:${2}\033[0m"
        catalog="false"
    fi
}

#####################文件检查#################
file_check(){
    if [ -f ${2} ];then
        echo -e "\033[31m ${1} 文件存在,路径:${2}\033[0m"
        file="ture"
    else
        echo -e "\033[32m ${1} 文件不存在,路径:${2}\033[0m"
        file="false"
    fi
}

###############################zabbix agent install########################
agentd_install(){
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

        run "mkdir -p ${BASEDIR}/{logs,run}"

        # 配置 zabbix_agentd.conf
        run "sed -i \"s/Server=127.0.0.1/Server=${Agent_Server}/g\" `grep Server= -rl $CONF_FILE`"
        run "sed -i \"s@Hostname=Zabbix server@Hostname=${Agent_Hostname}@g\" `grep Hostname= -rl ${CONF_FILE}`"
        run "sed -i \"s@LogFile=/tmp/zabbix_agentd.log@LogFile=${LogFile}@g\" `grep LogFile= -rl ${CONF_FILE}`"
        run "sed -i \"s@\# PidFile=/tmp/zabbix_agentd.pid@PidFile=${PidFile}@g\" `grep PidFile= -rl ${CONF_FILE}`"
        run "sed -i \"s@\# ListenPort=10050@ListenPort=${Agent_ListenPort}@g\" `grep ListenPort= -rl ${CONF_FILE}`"
        run "sed -i \"s@\# Timeout=3@Timeout=${Agent_Timeout}@g\" `grep Timeout= -rl ${CONF_FILE}`"
        run "sed -i \"s@ServerActive=127.0.0.1@ServerActive=${Agent_ServerActive}@g\" `grep ServerActive= -rl ${CONF_FILE}`"        
        # check parameter
        run "sed -i \"s@\# EnableRemoteCommands=0@EnableRemoteCommands=${Agent_EnableRemoteCommands}@g\" `grep EnableRemoteCommands= -rl ${CONF_FILE}`"
        run "sed -i \"s@\# LogRemoteCommands=0@LogRemoteCommands=${Agent_LogRemoteCommands}@g\" `grep LogRemoteCommands= -rl ${CONF_FILE}`"
        run "sed -i \"s@\# UnsafeUserParameters=0@UnsafeUserParameters=${Agent_UnsafeUserParameters}@g\" `grep UnsafeUserParameters= -rl ${CONF_FILE}`"
        run "sed -i \"s@\# StartAgents=3@StartAgents=${Agent_StartAgents}@g\" `grep StartAgents= -rl ${CONF_FILE}`"
        run "sed -i \"s@\# LogFileSize=1@LogFileSize=${Agent_LogFileSize}@g\" `grep LogFileSize= -rl ${CONF_FILE}`"
        run "sed -i \"s@\# HostMetadataItem=@HostMetadataItem=${Agent_HostMetadataItem}@g\" `grep HostMetadataItem= -rl ${CONF_FILE}`"
    fi
}

agentd_init(){
	parting "初始化zabbix_agentd"
    run "cp ${basepath}/${ZBBackageName}/misc/init.d/fedora/core/zabbix_agentd /etc/init.d/"
    run "chmod 755  /etc/init.d/zabbix_agentd"
    # 配置启动文件
    run "sed -i \"s@BASEDIR=/usr/local@BASEDIR=${BASEDIR}@g\" /etc/init.d/zabbix_agentd"
    run "sed -i \"s@PIDFILE=/tmp/\\\$BINARY_NAME.pid@PIDFILE=${BASEDIR}/logs/\\\$BINARY_NAME.pid@g\" /etc/init.d/zabbix_agentd"

    run "chown -R zabbix:zabbix ${BASEDIR}/"
    run "service zabbix_agentd start && ss -tnlp"

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
}

# Check Zabbix agentd Starting Status
agentd_status(){
    parting "agentd_status_check"
    local proc_num=`netstat -apn |grep zabbix_agentd |grep -v grep |wc -l`
    #if [ $c -eq "1" ];then
    if [ $proc_num -gt 0 ];then
        echo "Zabbix agentd Starting Success!"
    else
        echo "Zabbix agentd Starting ERROR!"
    fi
}

# Check Iptables Status
iptables_check(){
	parting "Check Iptables Status"
	if [ ${LinuxVersion:0:1} = "6" ];then
        if ! grep "10050" /etc/sysconfig/iptables;then
            run "sed -i '9a \-A INPUT \-m state \-\-state NEW \-m tcp \-p tcp \-\-dport '$Agent_ListenPort' \-j ACCEPT' /etc/sysconfig/iptables"
            run "sed -i '9a \-A OUTPUT \-m state \-\-state NEW \-m tcp \-p tcp \-\-dport '$Agent_ListenPort' \-j ACCEPT' /etc/sysconfig/iptables"
        else
            echo "iptables rules already exist!"
        fi
	elif [ ${LinuxVersion:0:1} = "7" ];then
        if ! firewall-cmd --list-port | grep "10050/tcp";then
		    run "firewall-cmd --add-port=$Agent_ListenPort/tcp"
		else
			echo "firewall rules already exist!"
		fi
	fi
}

Agentd_install(){
    Env
    user_group_check
    agentd_install
    agentd_init
    agentd_status
    iptables_check
}

Agentd_install 2>&1 |tee ${baseshell}/log

exit 0
