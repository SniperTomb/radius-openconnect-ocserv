function set_daloradius4(){
	cd /var/www/html/
	chown -R apache:apache /var/www/html/daloradius/
	chmod 664 /var/www/html/daloradius/library/daloradius.conf.php
	cd /var/www/html/daloradius/
	mysql -uradius -p'p0radius_0p' radius < contrib/db/fr2-mysql-daloradius-and-freeradius.sql
	mysql -uradius -p'p0radius_0p' radius < contrib/db/mysql-daloradius.sql
	sleep 3
	sed -i "s/\['CONFIG_DB_USER'\] = 'root'/\['CONFIG_DB_USER'\] = 'radius'/g"  /var/www/html/daloradius/library/daloradius.conf.php
	sed -i "s/\['CONFIG_DB_PASS'\] = ''/\['CONFIG_DB_PASS'\] = 'p0radius_0p'/g" /var/www/html/daloradius/library/daloradius.conf.php
	yum -y install epel-release
	yum -y install php-pear-DB
	systemctl restart mariadb.service 
	systemctl restart radiusd.service
	systemctl restart httpd
	chmod 644 /var/log/messages
	chmod 755 /var/log/radius/
	chmod 644 /var/log/radius/radius.log
	touch /tmp/daloradius.log
	chmod 644 /tmp/daloradius.log
	chown -R apache:apache /tmp/daloradius.log
}

function set_iptables6(){
cat >>  /etc/rc.local <<EOF
systemctl start mariadb
systemctl start httpd
systemctl start radiusd
iptables -I INPUT -p tcp --dport 9090 -j ACCEPT
EOF
systemctl start mariadb
systemctl start httpd
systemctl start radiusd
iptables -I INPUT -p tcp --dport 9090 -j ACCEPT
}

function set_web_config7(){
echo  "
Listen 9090
<VirtualHost *:9090>
 DocumentRoot "/var/www/html/daloradius"
 ServerName daloradius
 ErrorLog "logs/daloradius-error.log"
 CustomLog "logs/daloradius-access.log" common
</VirtualHost>
" >> /etc/httpd/conf/httpd.conf
cd /var/www/html/
rm -rf *
chown -R apache:apache /var/www/html/daloradius
service httpd restart
crontab /tmp/crontab.back
systemctl restart crond
}

function set_radiusclient8(){
systemctl restart ocserv
#
echo "==========================================================================
                  Centos7 VPN 安装完成                            
										 
				  以下信息将自动保存到/root/info.txt文件中			
          
                   mysql root用户密码:0p0o0i0900      

		          VPN 账号管理后台地址：http://$public_ip:9090
		                             账号：administrator 密码:radius
		           
			   如果使用Raidus 认证需要修改ocserv.conf 配置文件，本脚本已经修改
		           修改过程如下：
			   1、需要注释/etc/ocserv/ocserv.conf文件中的下面行密码认证行
			   auth = "plain[passwd=/etc/ocserv/ocpasswd]"
			   #下面的方法是使用radius验证用户，如果使用radius，请注释上面的密码验证
			   #auth = "radius[config=/etc/radiusclient-ng/radiusclient.conf,groupconfig=true]"
			   #下面这句加上之后，daloradius在线用户中可以看到用户在线
			   #acct = "radius[config=/etc/radiusclient-ng/radiusclient.conf]"
			   修改完成之后执行systemctl restart ocserv 命令重启ocserv

==========================================================================" > /root/info.txt
	cat /root/info.txt
	exit;
}

function shell_install() {
centos1_ntp
set_shell_input1
set_mysql2
set_freeradius3
set_daloradius4
set_fix_radacct_table5
set_iptables6
set_web_config7
set_radiusclient8
}
shell_install
