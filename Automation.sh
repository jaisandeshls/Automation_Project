#!bin/bash/

s3_bucket='upgrad-jaisandeshls'

sudo apt update -y

# check if apache2 is installed 

installed=`apt list --installed | grep apache2/ | cut -d / -f 1`

if [[ 'apache2' == $installed ]]
then
        echo "apache2 is present"

else
        echo "installing apache2...."
        apt install apache2 -y
fi

# check if the service is running

status=`systemctl status apache2.service | grep Active | cut -d : -f 2 | cut -d " " -f 2`

if [[ 'active' == $status ]]
then
        echo "apache2 server is running !!!"
else
        echo "starting the service..."
        systemctl start apache2.service
        systemctl status apache2.service
fi

# check if the service is enabled or not

enabled=`systemctl is-enabled apache2`

if [[ 'enabled' == $enabled ]]
then
        echo "service is enabled"
else
        echo "enabling the service.."
        systemctl enable apache2
fi

#creating tar files for logs and pushing them to s3 bucket

name='jaisandeshls'
timestamp=$(date '+%d%m%Y-%H%M%S')

cd /var/log/apache2

tar -cf /tmp/$name-httpd-logs-$timestamp.tar *.log

# copy the log files to Se-bucket
aws s3 cp /tmp/${name}-httpd-logs-${timestamp}.tar s3://${s3_bucket}/${name}-httpd-logs-${timestamp}.tar

#book keeping for logs
cd  /var/www/html/

if [[ ! -f inventory.html ]]
then
        echo -e "Log-Type\t \t Time-Created\t \t \t Type\t \t Size " > inventory.html
fi

size=$(du -h /tmp/${name}-httpd-logs-${timestamp}.tar | awk '{print $1}')

if [[ -f inventory.html ]]
then
        echo -e "httpd-logs\t \t ${timestamp}\t \t tar\t \t ${size} " >> inventory.html
fi

# Crontab job

if [[ ! -f /etc/cron.d/Automation ]]
then
    echo " 0 10 * * * root root/Automation_Project/automation.sh" > /etc/cron.d/Automation
fi


