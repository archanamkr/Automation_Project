#!/bin/bash
set -x
instance_update() {
        sudo apt update -y
        echo "Update completed"
        sleep 3
}
server_installation() {
        echo "http server installation"
        count=`dpkg --get-selections | grep apache | wc -l`
        if [ $count -eq 0 ]
        then
                echo "installing apache2"
                sudo apt-get install apache2
        fi
}
service_restart(){
        echo "checking if service is running"
        count=`service --status-all | grep apache2 | wc -l`
        sleep 3
        if [ $count != 0 ]; then
                echo "Process is running."
        else
                echo "Process is not running.Hence starting it"
                sudo service apache2 start
        fi
}
service_enabled() {
        count=`systemctl status apache2.service| grep enabled | wc -l`
        sleep 3
        if [ $count != 0 ]; then
                echo "Process is enabled."
        else
                echo "Process is not enabled.Hence enabling it"
        sudo systemctl enable apache2.service
        fi
}
upload_tar_logs() {
        echo "starting tar of apache2 logs"
        timestamp=$(date '+%d%m%Y-%H%M%S')
        myname=Archana
        s3_bucket=upgrad-archana
        tar -cvf /tmp/$myname-httpd-logs-$timestamp.tar /var/log/apache2/*.log
        aws s3 cp /tmp/$myname-httpd-logs-$timestamp.tar s3://$s3_bucket/$myname-httpd-logs-$timestamp.tar
}
instance_update
server_installation
service_restart
service_enabled
upload_tar_logs
