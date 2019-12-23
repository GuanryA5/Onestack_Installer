#!/bin/bash

show_menu(){
    echo
    echo
}
# 自定义Item文件目录
#run "sed -i \"s@\# Include=/usr/local/etc/zabbix_agentd.conf.d/@Include=${Include}@g\" `grep Include= -rl ${CONF_FILE}`"
################################ UserParameter自定义监控项 ###########################################

public_monitor(){
CHECK=`grep "基础监测" ${CONF_FILE} | wc -l`
if [[ ${CHECK} == 0 ]];then
    echo  -e "\n################################基础监测################################" >> ${CONF_FILE} && \
    # ICMP探测
    run "sed -i '\$aUserParameter=ping[*],ping \$1 -c \$2 > /dev/null && echo 1 || echo 0' ${CONF_FILE}"
    # TCP网络
    run "sed -i '\$aUserParameter=tcp.status[*],/usr/sbin/ss -ant|grep -c \$1' ${CONF_FILE}"
    # 磁盘IO性能
    
fi
}


disk_io(){
CHECK=`grep "磁盘监控" ${CONF_FILE} | wc -l`
if [[ ${CHECK} ==0 ]];then
    mkdir ${BASEDIR}/lib/diskio
    run "cp ${scripts}/discover_disk.pl ${BASEDIR}/lib/"
    run "chmod u+x ${BASEDIR}/lib/discover_disk.pl"
    run "sed -i '\$aUserParameter=discovery.disks.iostats,/usr/local/zabbix/lib/discover_disk.pl\n \
    UserParameter=vfs.dev.read.sectors[*],cat /proc/diskstats | grep \$1 | head -1 | awk '\''{print \$\$6}'\''\n \
    UserParameter=vfs.dev.write.sectors[*],cat /proc/diskstats | grep \$1 | head -1 | awk '\''{print \$\$10}'\''\n \
    UserParameter=vfs.dev.read.ops[*],cat /proc/diskstats | grep \$1 | head -1 |awk '\''{print \$\$4}'\''\n \
    UserParameter=vfs.dev.write.ops[*],cat /proc/diskstats | grep \$1 | head -1 | awk '\''{print \$\$8}'\''\n \
    UserParameter=vfs.dev.read.ms[*],cat /proc/diskstats | grep \$1 | head -1 | awk '\''{print \$\$7}'\''\n \
    UserParameter=vfs.dev.write.ms[*],cat /proc/diskstats | grep \$1 | head -1 | awk '\''{print \$\$11}'\''\n \
    UserParameter=user_disk,/usr/local/zabbix/lib/user_disk.sh' ${CONF_FILE}"
if 
}
