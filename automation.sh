
name="ritwik"
s3_bucket="upgrad-ritwik"

apt update -y


if [[ apache2 != $(dpkg --get-selections apache2 | awk '{print $1}') ]]; then
	
	apt install apache2 -y
fi


running=$(systemctl status apache2 | grep active | awk '{print $3}' | tr -d '()')
if [[ running != ${running} ]]; then
	
	systemctl start apache2
fi


enabled=$(systemctl is-enabled apache2 | grep "enabled")
if [[ enabled != ${enabled} ]]; then
	systemctl enable apache2
fi


timestamp=$(date '+%d%m%Y-%H%M%S')



tar -cf /tmp/${name}-httpd-logs-${timestamp}.tar *.log


	
	aws s3 cp /tmp/${name}-httpd-logs-${timestamp}.tar s3://${s3_bucket}/${name}-httpd-logs-${timestamp}.tar


logfile="/var/www/html"

if [[ ! -f ${logfile}/inventory.html ]]; then
	
	echo -e 'Log Type\t-\tTime Created\t-\tType\t-\tSize' > ${logfile}/inventory.html
fi

if [[ -f ${logfile}/inventory.html ]]; then
	
    size=$(du -h /tmp/${name}-httpd-logs-${timestamp}.tar | awk '{print $1}')
	echo -e "httpd-logs\t-\t${timestamp}\t-\ttar\t-\t${size}" >> ${logfile}/inventory.html
fi

if [[ ! -f /etc/cron.d/automation ]]; then
	
	echo "* * * * * root /root/automation.sh" >> /etc/cron.d/automation
fi
