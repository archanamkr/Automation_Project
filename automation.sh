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
book_keeping() {
        inventory_file="/var/www/html/inventory.html"
        if [ -f "$inventory_file" ]; then
                echo "$inventory_file exists."
        else
                echo "Creating $inventory_file"
                echo "LogType               DateCreated               Type      Size" >> $inventory_file
        fi
        size=`du -sh /tmp/$myname-httpd-logs-$timestamp.tar | awk  '{print $1}'`
        echo "httpd-logs                $timestamp              tar             $size" >> $inventory_file
}
cron_job() {
        cron_file="/etc/cron.d/automation"
        if [ -f "$cron_file" ]; then
            echo "$cron_file exists."
        else
                echo "Creating $cron_file"
                echo "5 2 * * * root sh /root/Automation_Project/automation.sh" >> $cron_file
        fi
}
instance_update
server_installation
service_restart
service_enabled
upload_tar_logs
book_keeping
cron_job
