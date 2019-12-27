#!/bin/bash

# Add/Update UserParameter File
cp -rf ${oneinstack_dir}/configure/zabbix_agentd-extra.conf ${Agent_Include}/.

# Add/Update Sudoer file
cp -rf ${oneinstack_dir}/configure/sudoer_zabbix

comman_monitor(){

}

apache_state(){
    
}