#!/bin/bash

Install_Zabbix_agent32(){
  pushd ${zabbix_install_dir}/src > /dev/null

  # Add user
  id -u ${zbx_user} > /dev/null 2>&1
  [ $? -ne 0 ] && useradd -M -s /sbin/nologin ${zbx_user}

  # Compiled installation 
  tar -xzf zabbix-${agent32_ver}.tar.gz 
  pushd zabbix-${agent32_ver} > /dev/null
  ./configure --prefix=${zabbix_install_dir} \
  --enable-agent
  make -j ${THREAD} && make install
  sleep 1
  
  # check parmaeter
  [ ! -d "`dirname ${Agent_PidFile}`" ] && mkdir `dirname ${Agent_PidFile}`
  [ $(grep -w "^PidFile=.*" ${zabbix_agent_conf_file} | wc -l) = '1' ] && sed -i 's@^PidFile=.*@PidFile=${Agent_PidFile}@' ${zabbix_agent_conf_file} || sed -i 's@\# PidFile=.* @PidFile=${Agent_PidFile}@' ${zabbix_agent_conf_file}
  
  [ ! -d "`dirname ${Agent_LogFile}`" ] && mkdir `dirname ${Agent_LogFile}`
  [ $(grep -w "^LogFile=.*" ${zabbix_agent_conf_file} | wc -l) = '1' ] && sed -i 's@^LogFile=.*@LogFile=${Agent_LogFile}@' ${zabbix_agent_conf_file} || sed -i 's@\# LogFile=.* @LogFile=${Agent_LogFile}@' ${zabbix_agent_conf_file}
  
  [ $(grep -w "^LogFileSize=.*" ${zabbix_agent_conf_file} | wc -l) = '1' ] && sed -i 's@^LogFileSize=.*@LogFileSize=${Agent_LogFileSize}@' ${zabbix_agent_conf_file} || sed -i 's@\# LogFileSize=.* @LogFileSize=${Agent_LogFileSize}@' ${zabbix_agent_conf_file}
  
  [ $(grep -w "^DebugLevel=.*" ${zabbix_agent_conf_file} | wc -l) = '1' ] && sed -i 's@^DebugLevel=.*@DebugLevel=${Agent_DebugLevel}@' ${zabbix_agent_conf_file} || sed -i 's@\# DebugLevel=.* @DebugLevel=${Agent_DebugLevel}@' ${zabbix_agent_conf_file}
  
  [ $(grep -w "^EnableRemoteCommands=.*" ${zabbix_agent_conf_file} | wc -l) = '1' ] && sed -i 's@^EnableRemoteCommands=.*@EnableRemoteCommands=${Agent_EnableRemoteCommands}@' ${zabbix_agent_conf_file} || sed -i 's@\# EnableRemoteCommands=.* @EnableRemoteCommands=${Agent_EnableRemoteCommands}@' ${zabbix_agent_conf_file}
  
  [ $(grep -w "^LogRemoteCommands=.*" ${zabbix_agent_conf_file} | wc -l) = '1' ] && sed -i 's@^LogRemoteCommands=.*@LogRemoteCommands=${Agent_LogRemoteCommands}@' ${zabbix_agent_conf_file} || sed -i 's@\# LogRemoteCommands=.* @LogRemoteCommands=${Agent_LogRemoteCommands}@' ${zabbix_agent_conf_file}
  
  [ $(grep -w "^Server=.*" ${zabbix_agent_conf_file} | wc -l) = '1' ] && sed -i 's@^Server=.*@Server=${Agent_Server}@' ${zabbix_agent_conf_file} || sed -i 's@\# Server=.* @Server=${Agent_Server}@' ${zabbix_agent_conf_file}
  
  [ $(grep -w "^ListenPort=.*" ${zabbix_agent_conf_file} | wc -l) = '1' ] && sed -i 's@^ListenPort=.*@ListenPort=${Agent_ListenPort}@' ${zabbix_agent_conf_file} || sed -i 's@\# ListenPort=.* @ListenPort=${Agent_ListenPort}@' ${zabbix_agent_conf_file}
  
  [ $(grep -w "^ListenIP=.*" ${zabbix_agent_conf_file} | wc -l) = '1' ] && sed -i 's@^ListenIP=.*@ListenIP=${Agent_ListenIP}@' ${zabbix_agent_conf_file} || sed -i 's@\# ListenIP=.* @ListenIP=${Agent_ListenIP}@' ${zabbix_agent_conf_file}
  
  [ $(grep -w "^StartAgents=.*" ${zabbix_agent_conf_file} | wc -l) = '1' ] && sed -i 's@^StartAgents=.*@StartAgents=${Agent_StartAgents}@' ${zabbix_agent_conf_file} || sed -i 's@\# StartAgents=.* @StartAgents=${Agent_StartAgents}@' ${zabbix_agent_conf_file}
  
  [ $(grep -w "^ServerActive=.*" ${zabbix_agent_conf_file} | wc -l) = '1' ] && sed -i 's@^ServerActive=.*@ServerActive=${Agent_ServerActive}@' ${zabbix_agent_conf_file} || sed -i 's@\# ServerActive=.* @ServerActive=${Agent_ServerActive}@' ${zabbix_agent_conf_file}
  
  [ $(grep -w "^Hostname=.*" ${zabbix_agent_conf_file} | wc -l) = '1' ] && sed -i 's@^Hostname=.*@Hostname=${Agent_Hostname}@' ${zabbix_agent_conf_file} || sed -i 's@\# Hostname=.* @Hostname=${Agent_Hostname}@' ${zabbix_agent_conf_file}
  
  [ $(grep -w "^HostnameItem=.*" ${zabbix_agent_conf_file} | wc -l) = '1' ] && sed -i 's@^HostnameItem=.*@HostnameItem=${Agent_HostnameItem}@' ${zabbix_agent_conf_file} || sed -i 's@\# HostnameItem=.* @HostnameItem=${Agent_HostnameItem}@' ${zabbix_agent_conf_file}
  
  [ $(grep -w "^HostMetadata=.*" ${zabbix_agent_conf_file} | wc -l) = '1' ] && sed -i 's@^HostMetadata=.*@HostMetadata=${Agent_HostMetadata}@' ${zabbix_agent_conf_file} || sed -i 's@\# HostMetadata=.* @HostMetadata=${Agent_HostMetadata}@' ${zabbix_agent_conf_file}
  
  [ $(grep -w "^HostMetadataItem=.*" ${zabbix_agent_conf_file} | wc -l) = '1' ] && sed -i 's@^HostMetadataItem=.*@HostMetadataItem=${Agent_HostMetadataItem}@' ${zabbix_agent_conf_file} || sed -i 's@\# HostMetadataItem=.* @HostMetadataItem=${Agent_HostMetadataItem}@' ${zabbix_agent_conf_file}
  
  [ $(grep -w "^RefreshActiveChecks=.*" ${zabbix_agent_conf_file} | wc -l) = '1' ] && sed -i 's@^RefreshActiveChecks=.*@RefreshActiveChecks=${Agent_RefreshActiveChecks}@' ${zabbix_agent_conf_file} || sed -i 's@\# RefreshActiveChecks=.* @RefreshActiveChecks=${Agent_RefreshActiveChecks}@' ${zabbix_agent_conf_file}
  
  [ $(grep -w "^BufferSend=.*" ${zabbix_agent_conf_file} | wc -l) = '1' ] && sed -i 's@^BufferSend=.*@BufferSend=${Agent_BufferSend}@' ${zabbix_agent_conf_file} || sed -i 's@\# BufferSend=.* @BufferSend=${Agent_BufferSend}@' ${zabbix_agent_conf_file}
  
  [ $(grep -w "^BufferSize=.*" ${zabbix_agent_conf_file} | wc -l) = '1' ] && sed -i 's@^BufferSize=.*@BufferSize=${Agent_BufferSize}@' ${zabbix_agent_conf_file} || sed -i 's@\# BufferSize=.* @BufferSize=${Agent_BufferSize}@' ${zabbix_agent_conf_file}
  
  [ $(grep -w "^MaxLinesPerSecond=.*" ${zabbix_agent_conf_file} | wc -l) = '1' ] && sed -i 's@^MaxLinesPerSecond=.*@MaxLinesPerSecond=${Agent_MaxLinesPerSecond}@' ${zabbix_agent_conf_file} || sed -i 's@\# MaxLinesPerSecond=.* @MaxLinesPerSecond=${Agent_MaxLinesPerSecond}@' ${zabbix_agent_conf_file}
  
  [ $(grep -w "^Timeout=.*" ${zabbix_agent_conf_file} | wc -l) = '1' ] && sed -i 's@^Timeout=.*@Timeout=${Agent_Timeout}@' ${zabbix_agent_conf_file} || sed -i 's@\# Timeout=.* @Timeout=${Agent_Timeout}@' ${zabbix_agent_conf_file}
  
  [ $(grep -w "^AllowRoot=.*" ${zabbix_agent_conf_file} | wc -l) = '1' ] && sed -i 's@^AllowRoot=.*@AllowRoot=${Agent_AllowRoot}@' ${zabbix_agent_conf_file} || sed -i 's@\# AllowRoot=.* @AllowRoot=${Agent_AllowRoot}@' ${zabbix_agent_conf_file}
  
  [ $(grep -w "^User=.*" ${zabbix_agent_conf_file} | wc -l) = '1' ] && sed -i 's@^User=.*@User=${zbx_user}@' ${zabbix_agent_conf_file} || sed -i 's@\# User=.* @User=${zbx_user}@' ${zabbix_agent_conf_file}
  
  [ ! -d "`dirname ${Agent_Include}`" ] && mkdir `dirname ${Agent_Include}`
  [ $(grep -w "^Include=.*" ${zabbix_agent_conf_file} | wc -l) = '1' ] && sed -i 's@^Include=.*@Include=${Agent_Include}@' ${zabbix_agent_conf_file} || sed -i 's@\# Include=.* @Include=${Agent_Include}@' ${zabbix_agent_conf_file}
  
  [ $(grep -w "^UnsafeUserParameters=.*" ${zabbix_agent_conf_file} | wc -l) = '1' ] && sed -i 's@^UnsafeUserParameters=.*@UnsafeUserParameters=${Agent_UnsafeUserParameters}@' ${zabbix_agent_conf_file} || sed -i 's@\# UnsafeUserParameters=.* @UnsafeUserParameters=${Agent_UnsafeUserParameters}@' ${zabbix_agent_conf_file}
  
  [ $(grep -w "^UserParameter=.*" ${zabbix_agent_conf_file} | wc -l) = '1' ] && sed -i 's@^UserParameter=.*@UserParameter=${Agent_UserParameter}@' ${zabbix_agent_conf_file} || sed -i 's@\# UserParameter=.* @UserParameter=${Agent_UserParameter}@' ${zabbix_agent_conf_file}
  
  [ $(grep -w "^LoadModulePath=.*" ${zabbix_agent_conf_file} | wc -l) = '1' ] && sed -i 's@^LoadModulePath=.*@LoadModulePath=${Agent_LoadModulePath}@' ${zabbix_agent_conf_file} || sed -i 's@\# LoadModulePath=.* @LoadModulePath=${Agent_LoadModulePath}@' ${zabbix_agent_conf_file}
  
  [ $(grep -w "^LoadModule=.*" ${zabbix_agent_conf_file} | wc -l) = '1' ] && sed -i 's@^LoadModule=.*@LoadModule=${Agent_LoadModule}@' ${zabbix_agent_conf_file} || sed -i 's@\# LoadModule=.* @LoadModule=${Agent_LoadModule}@' ${zabbix_agent_conf_file}

  # 添加启动文件 zabbix_agentd 到 /etc/init.d/.
  cp ./misc/init.d/fedora/core/zabbix_agentd /etc/init.d/
  chmod 755 /etc/init.d/zabbix_agentd
  sed -i 's@BASEDIR=/usr/local@BASEDIR=${zabbix_install_dir}@g' /etc/init.d/zabbix_agentd
  sed -i 's@PIDFILE=/tmp/$BINARY_NAME.pid@PIDFILE=${Agent_PidFile}/$BINARY_NAME.pid@g' /etc/init.d/zabbix_agentd
  
  # 添加开机启动
  cat /etc/rc.local | grep "service zabbix_agentd start" > /dev/null 2>&1
  if [ $? = '0' ];then
    echo; echo -e "${CMSG}[zabbix-agent] Start on boot Already Exists${CEND}"; echo
  elif
    cat /etc/rc.local | grep "exit 0" > /dev/null 2>&1
  then
    sed -i "s@exit 0@service zabbix_agentd start\nexit 0@g" /etc/rc.local
  else
    echo "service zabbix-agent start" >> /etc/rc.local
  fi

  # 添加防火墙
  if [ ${CentOS_ver} = '6' ] && ! grep "10050" /etc/sysconfig/iptables; then
    sed -i '9a -A INPUT -m state --state NEW -m tcp -p tcp --dport '${Agent_ListenPort}' -j ACCEPT' /etc/sysconfig/iptables
    sed -i '9a -A OUTPUT -m state --state NEW -m tcp -p tcp --dport '${Agent_ListenPort}' -j ACCEPT' /etc/sysconfig/iptables
    echo "${CMSG}[zabbix-agent] Iptables rules add success!"
  elif [ ${CentOS_ver} =  '7' ] && ! firewall-cmd --list-port | grep "10050/tcp"; then
    firewall-cmd --add-port=${Agent_ListenPort}/tcp --permanent
    firewall-cmd --reload
    echo "${CMSG}[zabbix-agent] Firewalld rules add sucess!"
  fi

  # 启动并检查启动状态
  chown -R zabbix:zabbix ${zabbix_install_dir}
  serivce zabbix_agentd start && ss -tlnp
  if [ "`netstat -apn |grep zabbix_agentd |grep -v grep |wc -l`" != '0' ]; then
    echo; echo -e "${CSUCCESS}[zabbix-agent] Start success, ZABBIX AGENT(ver=>${agent32_ver}${CEND}"; echo
  else
    echo; echo -e "${CFAILURE}[zabbix-agent] Start Faild, Please check log for more detail :${zabbix_install_dir}/install.log "
    kill -9 $$
  fi
}
