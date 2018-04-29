#!/bin/bash
#

####Functions####

Root_Check () {		## checks that the script runs as root
	if [[ $EUID -eq 0 ]]; then
		:
	else
		printf "$line\n"
		printf "The script needs to run with root privileges\n"
		printf "$line\n"
		exit 1
	fi
}

Log_And_Variables () {		## set log path and variables for installation logs, makes sure whether log folder exists and if not, create it
	####Variables####
	line=#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!
	whiptail_install_stderr_log=/var/log/LAMP-On-Demand/Error_whiptail_install.log
	whiptail_install_stdout_log=/var/log/LAMP-On-Demand/whiptail_install.log
	web_install_stderr_log=/var/log/LAMP-On-Demand/Error_websrv_install.log
	web_install_stdout_log=/var/log/LAMP-On-Demand/websrv_install.log
	web_service_stderr_log=/var/log/LAMP-On-Demand/Error_websrv_service.log
	web_service_stdout_log=/var/log/LAMP-On-Demand/websrv_service.log
	sql_install_stderr_log=/var/log/LAMP-On-Demand/Error_sqlsrv_install.log
	sql_install_stdout_log=/var/log/LAMP-On-Demand/sqlsrv_install.log
	sql_service_stdout_log=/var/log/LAMP-On-Demand/sqlsrv_service.log
	sql_service_stderr_log=/var/log/LAMP-On-Demand/Error_sqlsrv_service.log
	lang_install_stderr_log=/var/log/LAMP-On-Demand/Error_lang_install.log
	lang_install_stdout_log=/var/log/LAMP-On-Demand/lang_install.log
	lang_service_stderr_log=/var/log/LAMP-On-Demand/Error_lang_service.log
	lang_service_stdout_log=/var/log/LAMP-On-Demand/lang_service.log
	remi_reop_stderr_log=/var/log/LAMP-On-Demand/Error_remi_repo.log
	remi_reop_stdout_log=/var/log/LAMP-On-Demand/remi_repo.log
	firewall_log=/var/log/LAMP-On-Demand/firewall.log
	php_conf=/etc/httpd/conf.d/php.conf
	php_fpm_conf=/etc/php-fpm.d/www.conf
	php_ini_conf=/etc/php.ini
	log_folder=/var/log/LAMP-On-Demand
	tempLAMP=$log_folder/LAMP_choise.tmp
	apache_index_path=/var/www/html
	nginx_index_path=/usr/share/nginx/html
	nginx_conf_path=/etc/conf.d/default.conf
	my_index_html=$(printf "
	<!DOCTYPE html>
	<html>
		<head>
			<title>LAMP-On-Demand</title>
		</head>
		<body>
			<h1>This page is badly writen</h1>

			<p>Best Distro (from top to bottom)</p>

			<ul>
				<li>ArchLinux</li>
				<li>Manjaro</li>
				<li>Fedora</li>
				<li>OpenSuse</li>
				<li>SteamOS</li>
				<li>Debian</li>
			</ul>

			</body>
	</html>
	")
	nginx_conf_file=$(printf "
	server {
    listen       80;
    server_name  127.0.0.1;

    root   /usr/share/nginx/html;
    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ =404;
    }
    error_page 404 /404.html;
    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
        root /usr/share/nginx/html;
    }

    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_pass unix:/var/run/php-fpm/php-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
	}
	")
	####Variables####

	if [[ -d $index_path ]]; then
		:
	else
		mkdir -p $index_path
	fi

	if [[ -d $log_folder ]]; then
		:
	else
		mkdir -p $log_folder
	fi
}

Distro_Check () {		## checking the environment the user is currenttly running on to determine which settings should be applied
	cat /etc/*-release |grep ID |cut  -d "=" -f "2" |egrep "^arch$|^manjaro$" &> /dev/null

	if [[ $? -eq 0 ]]; then
	  	Distro_Val="arch"
	else
	  	:
	fi

  cat /etc/*-release |grep ID |cut  -d "=" -f "2" |egrep "^debian$|^\"Ubuntu\"$" &> /dev/null

  if [[ $? -eq 0 ]]; then
    	Distro_Val="debian"
  else
    	:
  fi

	cat /etc/*-release |grep ID |cut  -d "=" -f "2" |egrep "^\"centos\"$|^\"fedora\"$" &> /dev/null

	if [[ $? -eq 0 ]]; then
	   	Distro_Val="centos"
	else
		:
	fi
}

Whiptail_Check () {		## checks if whiptail is installed, if it doesn't then install whiptail
	command -v whiptail &> /dev/null
	if [[ $? -eq 0 ]]; then
		:
	elif [[ $? -eq 1 ]]; then
		printf "Whiptail is needed to run this script and it's not installed...\n"
		read -p "Would you like to install whiptail to run this script? [y/n]: " answer
		until [[ $answer =~ [y|Y|n|N] ]]; do
			printf "Invalid option\n"
			printf "Whiptail is not installed...\n"
			read -p "Would you like to install whiptail to run this script? [y/n]: " answer
		done
		if [[ $answer =~ [y|Y] ]]; then
			if [[ $Distro_Val =~ "centos" ]]; then
				yum install whiptail -y 2>> $whiptail_install_stderr_log_log >> $whiptail_install_stdout_log_log
			elif [[ $Distro_Val =~ "debian" ]]; then
				apt-get install whiptail -y 2>> $whiptail_install_stderr_log_log >> $whiptail_install_stdout_log_log
			fi
				if [[ $? -eq 0 ]]; then
					:
				else
					printf "$line\n"
					printf "Something went wrong during whiptail installation\n"
					printf "Please check the log file under /var/log/LAMP-On-Demand/Error_whiptail_install.log\n"
					printf "$line\n"
					exit 1
				fi
		elif [[ $answer =~ [n|N] ]]; then
			printf "$line\n"
			printf "Exiting, have a nice day!\n"
			printf "$line\n"
			exit 0
		fi
	fi

}

Web_Server_Installation () {		## choose which web server would you like to install
	## prompt the user with a menu to select whether to install apache or nginx web server
	whiptail --title "LAMP-On-Demand" \
	--menu "Please choose web server to install:" 15 55 5 \
	"Apache" "Open-source cross-platform web server" \
	"Nginx" "Web, reverse proxy server and more" \
	"<---Back" "Back to main menu" \
	"Exit" "Walk away from the path to LAMP stack :(" 2> $tempLAMP
	clear

	if [[ $(cat $tempLAMP) =~ "Apache" ]]; then
		if [[ $Distro_Val =~ "centos" ]]; then
			yum install httpd -y 2>> $web_install_stderr_log >> $web_install_stdout_log &
			{
				i=3
				while true ;do
					ps aux |egrep -Eo "$!" &> /dev/null
					if [[ $? -eq 0 ]]; then
						if [[ $i -le 94 ]]; then
							printf "$i\n"
							i=$(expr $i + 7)
							sleep 2.5
						else
							:
						fi
					else
						break
					fi
				done
				printf "96\n"
				sleep 0.5
				printf "98\n"
				sleep 0.5
				printf "100\n"
				sleep 1
			} |whiptail --gauge "Please wait while installing..." 6 50 0
		elif [[ $Distro_Val =~ "debian" ]]; then
			apt-get install apache2 -y 2>> $web_install_stderr_log >> $web_install_stdout_log &
			{
				i=3
				while true ;do
					ps aux |egrep -Eo "$!" &> /dev/null
					if [[ $? -eq 0 ]]; then
						if [[ $i -le 94 ]]; then
							printf "$i\n"
							i=$(expr $i + 7)
							sleep 2.5
						else
							:
						fi
					else
						break
					fi
				done
				printf "96\n"
				sleep 0.5
				printf "98\n"
				sleep 0.5
				printf "100\n"
				sleep 1
			} |whiptail --gauge "Please wait while installing..." 6 50 0
		fi
		if [[ $? -eq 0 ]]; then
			printf "$line\n"
			printf "Apache installation completed successfully, have a nice day!\n"
			printf "$line\n"
		else
			printf "$line\n"
			printf "Something went wrong during Apache installation\n"
			printf "Please check the log file under $web_install_stderr_log\n"
			printf "$line\n"
			exit 1
		fi
	elif [[ $(cat $tempLAMP) =~ "Nginx" ]]; then
		if [[ $Distro_Val =~ "centos" ]]; then
			yum --enablerepo=epel -y install nginx 2>> $web_install_stderr_log >> $web_install_stdout_log
		elif [[ $Distro_Val =~ "debian" ]]; then
			apt-get install nginx -y 2>> $web_install_stderr_log >> $web_install_stdout_log
		fi
		if [[ $? -eq 0 ]]; then
			printf "$line\n"
			printf "Nginx installation completed successfully, have a nice day!\n"
			printf "$line\n"
		else
			printf "$line\n"
			printf "Something went wrong during Nginx installation\n"
			printf "Please check the log file under $web_install_stderr_log\n"
			printf "$line\n"
			exit 1
		fi

	elif [[ "$(cat $tempLAMP)" == "<---Back" ]]; then
		Main_Menu

	elif [[ "$(cat $tempLAMP)" =~ "Exit" ]]; then
		printf "$line\n"
		printf "Exit - I hope you feel safe now\n"
		printf "$line\n"
	fi
	}

Web_Server_Configuration () {		## start the web server's service
	if [[ "$(cat $tempLAMP)" =~ "Apache" ]]; then
		$my_index_html > $apache_index_path
		if [[ $Distro_Val =~ "centos" ]]; then
			systemctl enable httpd 2>> $web_service_stderr_log >> $web_service_stdout_log
			if [[ $? -eq 0 ]]; then
				:
			else
				printf "$line\n"
				printf "Something went wrong while enabling the service\n"
				printf "Please check the log file under $web_service_stderr_log\n"
				printf "$line\n"
				exit 1
			fi
			systemctl restart httpd 2>> $web_service_stderr_log >> $web_service_stdout_log
			if [[ $? -eq 0 ]]; then
				printf "$line\n"
				printf "Apache web server is up and running!"
				printf "$line\n"
			else
				printf "$line\n"
				printf "Something went wrong while enabling the service\n"
				printf "Please check the log file under $web_service_stderr_log\n"
				printf "$line\n"
				exit 1
			fi
			systemctl status firewalld |awk '{print $2}' |egrep 'active' &> /dev/null
			if [[ $? -eq 0 ]]; then
				firewall-cmd --add-service=http --permanent &> $firewall_log
				if [[ $? -eq 0 ]]; then
					:
				else
					printf "$line\n"
					printf "Failed to add HTTP service to firewall rules\n"
					printf "$line\n"
				fi
				firewall-cmd --reload
				if [[ $? -eq 0 ]]; then
					:
				else
					printf "$line\n"
					printf "Failed to reload firewall\n"
					printf "$line\n"
				fi
			else
				:
			fi
		elif [[ $Distro_Val =~ "debian" ]]; then
			systemctl enable apache2 2>> $web_service_stderr_log >> $web_service_stdout_log
			if [[ $? -eq 0 ]]; then
				:
			else
				printf "$line\n"
				printf "Something went wrong while enabling the service\n"
				printf "Please check the log file under $web_service_stderr_log\n"
				printf "$line\n"
				exit 1
			fi
			systemctl restart apache2 2>> $web_service_stderr_log >> $web_service_stdout_log
			if [[ $? -eq 0 ]]; then
				printf "$line\n"
				printf "Apache web server is up and running!"
				printf "$line\n"
			else
				printf "$line\n"
				printf "Something went wrong while enabling the service\n"
				printf "Please check the log file under $web_service_stderr_log\n"
				printf "$line\n"
				exit 1
			fi
		fi
	elif [[ "$(cat $tempLAMP)" =~ "Nginx" ]]; then
		$my_index_html > $nginx_index_path
		systemctl enable nginx 2>> $web_service_stderr_log >> $web_service_stdout_log
		if [[ $? -eq 0 ]] ;then
			:
		else
			printf "$line\n"
			printf "Something went wrong while enabling the service\n"
			printf "Please check the log file under $web_service_stderr_log\n"
			printf "$line\n"
			exit 1
		fi
		systemctl restart nginx 2>> $web_service_stderr_log >> $web_service_stdout_log
		if [[ $? -eq 0 ]] ;then
			printf "$line\n"
			printf "Nginx web server is up and running!"
			printf "$line\n"
		else
			printf "$line\n"
			printf "Something went wrong while enabling the service\n"
			printf "Please check the log file under $web_service_stderr_log\n"
			printf "$line\n"
			exit 1
		fi
		if [[ $Distro_Val =~ "centos" ]]; then
			systemctl status firewalld |awk '{print $2}' |egrep 'active' &> /dev/null
			if [[ $? -eq 0 ]]; then
				firewall-cmd --add-service=http --permanent &> $firewall_log
				if [[ $? -eq 0 ]]; then
					:
				else
					printf "$line\n"
					printf "Failed to add HTTP service to firewall rules\n"
					printf "$line\n"
				fi
				firewall-cmd --reload
				if [[ $? -eq 0 ]]; then
					:
				else
					printf "$line\n"
					printf "Failed to reload firewall\n"
					printf "$line\n"
				fi
			else
				:
			fi
		else
			:
		fi
	fi
}

Sql_Server_Installation () {		## choose which data base server would you like to install
	## prompt the user with a menu to select whether to install apache or nginx web server
	whiptail --title "LAMP-On-Demand" \
	--menu "Please choose sql server to install:" 15 55 5 \
	"MariaDB" "Fork of the MySQL relational database"\
	"PostgreSQL" "Object-relational database" \
	"<---Back" "Back to main menu" \
	"Exit" "Walk away from the path to LAMP stack :(" 2> $tempLAMP

	if [[ "$(cat $tempLAMP)" =~ "MariaDB" ]]; then
		if [[ $Distro_Val =~ "centos" ]]; then
			yum install mariadb-server mariadb -y 2>> $sql_install_stderr_log >> $sql_install_stdout_log &
			{
				i=3
				while true ;do
					ps aux |egrep -Eo "$!" &> /dev/null
					if [[ $? -eq 0 ]]; then
						if [[ $i -le 94 ]]; then
							printf "$i\n"
							i=$(expr $i + 7)
							sleep 2.5
						else
							:
						fi
					else
						break
					fi
				done
				printf "96\n"
				sleep 0.5
				printf "98\n"
				sleep 0.5
				printf "100\n"
				sleep 1
			} |whiptail --gauge "Please wait while installing..." 6 50 0
		elif [[ $Distro_Val =~ "debian" ]]; then
			apt-get install mariadb-server mariadb-client -y 2>> $sql_install_stderr_log >> $sql_install_stdout_log
		fi

		if [[ $? -eq 0 ]]; then
			printf "$line\n"
			printf "MariaDB installation completed successfully, have a nice day!\n"
			printf "$line\n"
		else
			printf "$line\n"
			printf "Something went wrong during MariaDB installation\n"
			printf "Please check the log file under $sql_install_stderr_log\n"
			printf "$line\n"
			exit 1
		fi

	elif [[ "$(cat $tempLAMP)" =~ "PostgreSQL" ]]; then
		if [[ $Distro_Val =~ "centos" ]]; then
			yum install postgresql-server postgresql-contrib -y 2>> $sql_install_stderr_log >> $sql_install_stdout_log &
			{
				i=3
				while true ;do
					ps aux |egrep -Eo "$!" &> /dev/null
					if [[ $? -eq 0 ]]; then
						if [[ $i -le 94 ]]; then
							printf "$i\n"
							i=$(expr $i + 7)
							sleep 2.5
						else
							:
						fi
					else
						break
					fi
				done
				printf "96\n"
				sleep 0.5
				printf "98\n"
				sleep 0.5
				printf "100\n"
				sleep 1
			} |whiptail --gauge "Please wait while installing..." 6 50 0
		elif [[ $Distro_Val =~ "debian" ]]; then
			apt-get install postgresql postgresql-contrib -y 2>> $sql_install_stderr_log >> $sql_install_stdout_log &
			{
				i=3
				while true ;do
					ps aux |egrep -Eo "$!" &> /dev/null
					if [[ $? -eq 0 ]]; then
						if [[ $i -le 94 ]]; then
							printf "$i\n"
							i=$(expr $i + 7)
							sleep 2.5
						else
							:
						fi
					else
						break
					fi
				done
				printf "96\n"
				sleep 0.5
				printf "98\n"
				sleep 0.5
				printf "100\n"
				sleep 1
			} |whiptail --gauge "Please wait while installing..." 6 50 0
		fi
		if [[ $? -eq 0 ]]; then
			printf "$line\n"
			printf "PostgreSQL installation completed successfully, have a nice day!\n"
			printf "$line\n"
		else
			printf "$line\n"
			printf "Something went wrong during PostgreSQL installation\n"
			printf "Please check the log file under $sql_install_stderr_log\n"
			printf "$line\n"
			exit 1
		fi

	elif [[ "$(cat $tempLAMP)" == "<---Back" ]]; then
		Main_Menu

	elif [[ "$(cat $tempLAMP)" =~ "Exit" ]]; then
		whiptail --title "LAMP-On-Demand" \
		--msgbox "\nExit - I hope you feel safe now." 8 78
		exit 0
	fi
}

Sql_Server_Configuration () {		## configure data base
	if [[ "$(cat $tempLAMP)" =~ "MariaDB" ]]; then
		mysql_secure_installation
		if [[ $? -eq 0 ]]; then
			:
		else
			printf "$line\n"
			printf "Failed to securly configure mysql server\n"
			printf "$line\n"
		fi

		systemctl enable mariadb 2>> $sql_service_stderr_log >> $sql_service_stdout_log
		if [[ $? -eq 0 ]]; then
			:
		else
			printf "$line\n"
			printf "Something went wrong while enabling the service\n"
			printf "Please check the log file under $sql_service_stderr_log\n"
			printf "$line\n"
			exit 1
		fi
		systemctl restart mariadb 2>> $sql_service_stderr_log >> $sql_service_stdout_log
		if [[ $? -eq 0 ]] ;then
			printf "$line\n"
			printf "MariaDB sql server is up and running!"
			printf "$line\n"
		else
			printf "$line\n"
			printf "Something went wrong while enabling the service\n"
			printf "Please check the log file under $sql_service_stderr_log\n"
			printf "$line\n"
			exit 1
		fi

		if [[ $Distro_Val =~ "centos" ]]; then
			systemctl status firewalld |awk '{print $2}' |egrep 'active' &> /dev/null
			if [[ $? -eq 0 ]]; then
				firewall-cmd --add-service=mysql --permanent &> $firewall_log
				if [[ $? -eq 0 ]]; then
					:
				else
					printf "$line\n"
					printf "Failed to add MySQL service to firewall rules\n"
					printf "$line\n"
				fi
				firewall-cmd --reload
				if [[ $? -eq 0 ]]; then
					:
				else
					printf "$line\n"
					printf "Failed to reload firewall\n"
					printf "$line\n"
				fi
			else
				:
			fi
		else
			:
		fi

	elif [[ "$(cat $tempLAMP)" =~ "PostgreSQL" ]]; then
		systemctl enable postgresql 2>> $sql_service_stderr_log >> $sql_service_stdout_log
		if [[ $? -eq 0 ]]; then
			:
		else
			whiptail --title "LAMP-On-Demand" \
			--msgbox "\nSomething went wrong while enabling the service.\nPlease check the log file under $sql_service_stderr_log" 8 78
			exit 1
		fi
		systemctl restart postgresql 2>> $sql_service_stderr_log >> $sql_service_stdout_log
		if [[ $? -eq 0 ]]; then
			whiptail --title "LAMP-On-Demand" \
			--msgbox "\nPostgresql server is up and running!" 8 78
			Main_Menu
		else
			whiptail --title "LAMP-On-Demand" \
			--msgbox "\nSomething went wrong while restarting the service.\nPlease check the log file under $sql_service_stderr_log" 8 78
			exit 1
		fi
		if [[ $Distro_Val =~ "centos" ]]; then
			systemctl status firewalld |awk '{print $2}' |egrep 'active' &> /dev/null
			if [[ $? -eq 0 ]]; then
				firewall-cmd --add-service=mysql --permanent &> $firewall_log
				if [[ $? -eq 0 ]]; then
					:
				else
					whiptail --title "LAMP-On-Demand" \
					--msgbox "\nFailed to add MySQL service to firewall rules.\nPlease check the log file under $firewall_log" 8 78
					exit 1
				fi
				firewall-cmd --reload
				if [[ $? -eq 0 ]]; then
					Main_Menu
				else
					whiptail --title "LAMP-On-Demand" \
					--msgbox "\nFailed to reload firewall.\nPlease check the log file under $firewall_log" 8 78
					exit 1
				fi
			else
				Main_Menu
			fi
		else
			Main_Menu
		fi
	fi
}

Main_Menu () {

	whiptail --title "LAMP-On-Demand" \
	--menu "Please choose what whould you like to install:" 15 40 5 \
	"Web server" "Apache2, Nginx" \
	"DataBase server" "MariaDB, PostgreSQL" \
	"Exit" "Walk away from the path to LAMP stack :(" 2> $tempLAMP

	if [[ "$(cat $tempLAMP)" == "Web server" ]]; then
		Web_Server_Installation
		Web_Server_Configuration
	elif [[ "$(cat $tempLAMP)" == "DataBase server" ]]; then
		Sql_Server_Installation
		Sql_Server_Configuration
	elif [[ "$(cat $tempLAMP)" == "Exit" ]]; then
		whiptail --title "LAMP-On-Demand" \
		--msgbox "\nExit - I hope you feel safe now." 8 78
		exit 0
	fi
}

Root_Check
Distro_Check
Log_And_Variables
Whiptail_Check
Main_Menu
