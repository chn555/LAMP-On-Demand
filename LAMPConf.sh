#!/bin/bash


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
	web_install_stderr_log=/var/log/LAMP-On-Demand/Error_websrv_install.log
	sql_install_stderr_log=/var/log/LAMP-On-Demand/Error_sqlsrv_install.log
	lang_install_stderr_log=/var/log/LAMP-On-Demand/Error_lang_install.log
	web_service_stderr_log=/var/log/LAMP-On-Demand/Error_websrv_service.log
	sql_service_stderr_log=/var/log/LAMP-On-Demand/Error_sqlsrv_service.log
	whiptail_install_stdout_log=/var/log/LAMP-On-Demand/whiptail_install.log
	web_install_stdout_log=/var/log/LAMP-On-Demand/websrv_install.log
	sql_install_stdout_log=/var/log/LAMP-On-Demand/sqlsrv_install.log
	lang_install_stdout_log=/var/log/LAMP-On-Demand/lang_install.log
	web_service_stdout_log=/var/log/LAMP-On-Demand/websrv_service.log
	sql_service_stdout_log=/var/log/LAMP-On-Demand/sqlsrv_service.log
	firewall_log=/var/log/LAMP-On-Demand/firewall.log
	log_folder=/var/log/LAMP-On-Demand
	tempLAMP=$log_folder/LAMP_choise.tmp
	apache_index_path=/var/www/html
	nginx_index_path=/usr/share/nginx/html
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
		printf "Whiptail is not installed...\n"
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
	"Exit" "Walk away from the path to LAMP stack :(" 2> $tempLAMP
	clear

	if [[ $(cat $tempLAMP) =~ "Apache" ]]; then
		if [[ $Distro_Val =~ "centos" ]]; then
			yum install httpd -y 2>> $web_install_stderr_log >> $web_install_stdout_log
		elif [[ $Distro_Val =~ "debian" ]]; then
			apt-get install apache2 -y 2>> $web_install_stderr_log >> $web_install_stdout_log
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
	"Exit" "Walk away from the path to LAMP stack :(" 2> $tempLAMP

	if [[ "$(cat $tempLAMP)" =~ "MariaDB" ]]; then
		if [[ $Distro_Val =~ "centos" ]]; then
			yum install mariadb-server mariadb -y 2>> $sql_install_stderr_log >> $sql_install_stdout_log
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
			yum install postgresql-server postgresql-contrib -y 2>> $sql_install_stderr_log >> $sql_install_stdout_log
		elif [[ $Distro_Val =~ "debian" ]]; then
			apt-get install postgresql postgresql-contrib -y 2>> $sql_install_stderr_log >> $sql_install_stdout_log
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
	elif [[ "$(cat $tempLAMP)" =~ "Exit" ]]; then
		printf "$line\n"
		printf "Exit - I hope you feel safe now\n"
		printf "$line\n"
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
			printf "$line\n"
			printf "Something went wrong while enabling the service\n"
			printf "Please check the log file under $sql_service_stderr_log\n"
			printf "$line\n"
			exit 1
		fi
		systemctl restart postgresql 2>> $sql_service_stderr_log >> $sql_service_stdout_log
		if [[ $? -eq 0 ]]; then
			printf "$line\n"
			printf "Postgresql server is up and running!"
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
	fi
}

Lang_Installation () {	## installs language support of user choice
	whiptail --title "LAMP-On-Demand" \
	--menu "Please choose lang server to install:" 15 55 5 \
	"PHP 5.4" "PHP Version 5.4" \
	"PHP 7.0" "PHP Version 7.0" \
	"Python" "Python Version 2.7" \
	"Exit" "Walk away from the path to LAMP stack :(" 2> $tempLAMP

	if [[ "$(cat $tempLAMP)" =~ "PHP" ]]; then
		if [[ $Distro_Val =~ "centos" ]]; then
			yum install php php-mysql -y 2>> $lang_install_stderr_log >> $lang_install_stdout_log
		elif [[ $Distro_Val =~ "debian" ]]; then
			apt-get install php php-mysql -y 2>> $lang_install_stderr_log >> $sql_install_stdout_log
		fi
		systemctl restart httpd 2>> $web_service_stderr_log >> $web_service_stdout_log
		if [[ $? -eq 0 ]]; then
			printf "$line\n"
			printf "PHP support is up and running!"
			printf "$line\n"
		else
			printf "$line\n"
			printf "Something went wrong while enabling the service\n"
			printf "Please check the log file under $web_service_stderr_log\n"
			printf "$line\n"
			exit 1
		fi
	elif [[ "$(cat $tempLAMP)" =~ "Exit" ]]; then
		printf "$line\n"
		printf "Exit - I hope you feel safe now\n"
		printf "$line\n"
	fi
}
Root_Check
Distro_Check
Log_And_Variables
Whiptail_Check
Web_Server_Installation
Web_Server_Configuration
Sql_Server_Installation
Sql_Server_Configuration
