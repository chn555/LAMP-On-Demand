#!/bin/bash



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
	apache_index_path=/var/www/html/index.html
	nginx_index_path=/usr/share/nginx/html
	nginx_conf_path=/etc/conf.d/default.conf

	if [[ -d $log_folder ]]; then
		:
	else
		mkdir -p $log_folder
	fi
}

Web_Server_Installation () {		## choose which web server would you like to install
	## prompt the user with a menu to select whether to install apache or nginx web server
  Web_Server_Installation_Options="Apache Ngnix"
  select Web_Server in $Web_Server_Installation_Options; do
  	if [[ $Web_Server =~ "Apache" ]]; then
  		if [[ $Distro_Val =~ "centos" ]]; then
  			yum install httpd -y 2>> $web_install_stderr_log >> $web_install_stdout_log
  		elif [[ $Distro_Val =~ "debian" ]]; then
  			apt-get install apache2 -y 2>> $web_install_stderr_log >> $web_install_stdout_log
  		fi
  		if [[ $? -eq 0 ]]; then
  			printf "$line\n"
  			printf "Apache installation completed successfully, have a nice day!\n"
  			printf "$line\n"
        exit 0
  		else
  			printf "$line\n"
  			printf "Something went wrong during Apache installation\n"
  			printf "Please check the log file under $web_install_stderr_log\n"
  			printf "$line\n"
  			exit 1
  		fi
  	elif [[  $Web_Server =~ "Nginx" ]]; then
  		if [[ $Distro_Val =~ "centos" ]]; then
  			yum --enablerepo=epel -y install nginx 2>> $web_install_stderr_log >> $web_install_stdout_log
  		elif [[ $Distro_Val =~ "debian" ]]; then
  			apt-get install nginx -y 2>> $web_install_stderr_log >> $web_install_stdout_log
  		fi
  		if [[ $? -eq 0 ]]; then
  			printf "$line\n"
  			printf "Nginx installation completed successfully, have a nice day!\n"
  			printf "$line\n"
        exit 0
  		else
  			printf "$line\n"
  			printf "Something went wrong during Nginx installation\n"
  			printf "Please check the log file under $web_install_stderr_log\n"
  			printf "$line\n"
  			exit 1
  		fi
  	elif [[ $Web_Server == "<---Back" ]]; then
  		Main_Menu
  	elif [[ $Web_Server =~ "Exit" ]]; then
  		printf "$line\n"
  		printf "Exit - I hope you feel safe now\n"
  		printf "$line\n"
      exit 0
  	fi
  done
	}

Main_Menu () {
  Main_Menu_Options="Web_Server DataBase_Server Exit"
  select Entry in $Main_Menu_Options; do
  	if [[ $Entry == "Web_Server" ]]; then
  		Web_Server_Installation
  		Web_Server_Configuration
  	elif [[ $Entry == "DataBase_Server" ]]; then
  		Sql_Server_Installation
  		Sql_Server_Configuration
  	elif [[ $Entry == "Exit" ]]; then
  		printf "\nExit - I hope you feel safe now.\n"
  		exit 0
  	fi
	done
  }

Root_Check
Distro_Check
Log_And_Variables
Main_Menu
