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

Log_Path () {		## set log path and variables for installation logs, makes sure whether log folder exists and if not, create it
	whiptail_stderr_log=/var/log/LAMP-On-Demand/Error_whiptail_install.log
	whiptail_stdout_log=/var/log/LAMP-On-Demand/whiptail_install.log
	web_install_stderr_log=/var/log/LAMP-On-Demand/Error_websrv_install.log
	web_install_stdout_log=/var/log/LAMP-On-Demand/websrv_install.log
	web_service_stderr_log=/var/log/LAMP-On-Demand/Error_websrv_service.log
	web_service_stdout_log=/var/log/LAMP-On-Demand/websrv_service.log
	sql_install_stderr_log=/var/log/LAMP-On-Demand/Error_sqlsrv_install.log
	sql_install_stdout_log=/var/log/LAMP-On-Demand/sqlsrv_install.log
	sql_service_stderr_log=/var/log/LAMP-On-Demand/Error_sqlsrv_service.log
	sql_service_stdout_log=/var/log/LAMP-On-Demand/sqlsrv_service.log
	log_folder=/var/log/LAMP-On-Demand
	tempLAMP=$log_folder/LAMP_choise.tmp

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
	command -v whiptail
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
				yum install whiptail -y 2>> $whiptail_stderr_log >> $whiptail_stdout_log
			elif [[ $Distro_Val =~ "debian" ]]; then
				apt-get install whiptail -y 2>> $whiptail_stderr_log >> $whiptail_stdout_log
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
	####Variables & Function calls####
	Root_Check
	Distro_Check
	Log_Path
	Whiptail_Check
	line=#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!
	# local PS3="Please select the web server that you would like to install and press enters: "
	####Variables & Function calls####

	## prompt the user with a menu to select whether to install apache or nginx web server
	whiptail --title "LAMP-On-Demand" \
	--menu "Please choose web server to install:" 15 55 5 \
	"Apache" "Apache web server" \
	"Ngnix" "Nginx web server" \
	"Exit" "Walk away from the path to LAMP stack :(" 2> $tempLAMP

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
			Web_Server=Apache
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
			printf "Ngnix installation completed successfully, have a nice day!\n"
			printf "$line\n"
			Web_Server=Nginx
		else
			printf "$line\n"
			printf "Something went wrong during Ngnix installation\n"
			printf "Please check the log file under $web_install_stderr_log\n"
			printf "$line\n"
			exit 1
		fi
	elif [[ $(cat $tempLAMP) =~ "Exit" ]]; then
		printf "$line\n"
		printf "Exit - I hope you feel safe now\n"
		printf "$line\n"
	fi
	}

Web_Server_Configuration () {		## start the web server's service
<<<<<<< HEAD
	Web_server_Installation
	if [[ $web_server =~ "Apache" ]]; then
=======
	Web_Server_Installation

	if [[ $Web_Server =~ "Apache" ]]; then
>>>>>>> 8035080b5829e266ee4c7a86f971aa223a5411a5
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
			httpd_exit=$?
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
			apache_exit=$?
		fi
		if [[ $httpd_exit == 0 || $apache_exit == 0 ]]; then
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
	elif [[ $Web_Server =~ "Nginx" ]]; then
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
		systemctl restart nginx
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
	fi
}

Sql_Server_Installation () {		## choose which web server would you like to install

	## prompt the user with a menu to select whether to install apache or nginx web server
	whiptail --title "LAMP-On-Demand" \
	--menu "Please choose sql server to install:" 15 55 5 \
	"MariaDB" \
	"PostgreSQL" \
	"Exit" "from the path to LAMP stack :(" 2> $tempLAMP

	if [[ $tempLAMP =~ "MariaDB" ]]; then
		if [[ $Distro_Val =~ "centos" ]]; then
			yum install  mariadb-server -y 2>> $sql_install_stderr_log >> $sql_install_stdout_log
		elif [[ $Distro_Val =~ "debian" ]]; then
			apt-get install mariadb-server mariadb-client -y 2>> $sql_install_stderr_log >> $sql_install_stdout_log
		fi
		if [[ $? -eq 0 ]]; then
			printf "$line\n"
			printf "MariaDB installation completed successfully, have a nice day!\n"
			printf "$line\n"
			sql_server="MariaDB"
		else
			printf "$line\n"
			printf "Something went wrong during MariaDB installation\n"
			printf "Please check the log file under $sql_install_stderr_log\n"
			printf "$line\n"
			exit 1
		fi
	elif [[ $tempLAMP =~ "PostgreSQL" ]]; then
		if [[ $Distro_Val =~ "centos" ]]; then
			yum  -y install  postgresql-server postgresql-contrib -y 2>> $sql_install_stderr_log >> $sql_install_stdout_log
		elif [[ $Distro_Val =~ "debian" ]]; then
			apt-get install postgresql postgresql-contrib -y 2>> $sql_install_stderr_log >> $sql_install_stdout_log
		fi
		if [[ $? -eq 0 ]]; then
			printf "$line\n"
			printf "PostgreSQL installation completed successfully, have a nice day!\n"
			printf "$line\n"
			web_server=Nginx
		else
			printf "$line\n"
			printf "Something went wrong during PostgreSQL installation\n"
			printf "Please check the log file under $sql_install_stderr_log\n"
			printf "$line\n"
			exit 1
		fi
	elif [[ $tempLAMP =~ "Exit" ]]; then
		printf "$line\n"
		printf "Exit - I hope you feel safe now\n"
		printf "$line\n"
	fi
	}

Sql_Server_Configuration () {		## start the web server's service
	Sql_Server_Installation
	if [[ $web_server =~ "MariaDB" ]]; then
		if [[ $Distro_Val =~ "centos" ]]; then
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
			fi		elif [[ $Distro_Val =~ "debian" ]]; then
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
		fi

	elif [[ $sql_server =~ "PostgreSQL" ]]; then
		sudo /etc/init.d/postgresql reload
		if [[ $? -eq 0 ]] ;then
			printf "$line\n"
			printf "PostgreSQL  server is up and running!"
			printf "$line\n"
		else
			printf "$line\n"
			printf "Something went wrong while enabling the service\n"
			printf "Please check the log file under $sql_service_stderr_log\n"
			printf "$line\n"
			exit 1
		fi
	fi
}
