#!/bin/bash


####Functions####

For_The_Looks () {		## for decoration output only
	  line=#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!
}

Root_Check () {		## checks that the script runs as root
	if [[ $EUID -eq 0 ]]; then
		:
	else
		printf "$line\n"
		printf "The script needs to run with root privileges\n"
		printf "$line\n"
		exit
	fi
}

Log_Path () {		## set log path and variables for installation logs, makes sure whether log folder exists and if not, create it
	dialog_stderr_log=/var/log/LAMP-On-Demand/Error_dialog_install.log
	dialog_stdout_log=/var/log/LAMP-On-Demand/dialog_install.log
	web_install_stderr_log=/var/log/LAMP-On-Demand/Error_websrv_install.log
	web_install_stdout_log=/var/log/LAMP-On-Demand/websrv_install.log
	web_service_stderr_log=/var/log/LAMP-On-Demand/Error_websrv_service.log
	web_service_stdout_log=/var/log/LAMP-On-Demand/websrv_service.log
	log_folder=/var/log/LAMP-On-Demand

	if [[ -d $log_folder ]]; then
		:
	else
		mkdir $log_folder
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

Dialog_Check () {		## checks if dialog is installed, if it doesn't then install dialog
	command -v dialog
	if [[ $? -eq 0 ]]; then
		:
	elif [[ $? -eq 1 ]]; then
		printf "Dialog is not installed...\n"
		read -p "Would you like to install dialog to run this script? [y/n]: " answer
		until [[ $answer =~ [y|Y|n|N] ]]; do
			printf "Invalid option\n"
			printf "Dialog is not installed...\n"
			read -p "Would you like to install dialog to run this script? [y/n]: " answer
		done
		if [[ $answer =~ [y|Y] ]]; then
			if [[ $Distro_Val =~ "centos" ]]; then
				yum install dialog -y 2>> $dialog_stderr_log >> $dialog_stdout_log
			elif [[ $Distro_Val =~ "debian" ]]; then
				apt-get install dialog -y 2>> $dialog_stderr_log >> $dialog_stdout_log
			fi
				if [[ $? -eq 0 ]]; then
					:
				else
					printf "$line\n"
					printf "Something went wrong during dialog installation\n"
					printf "Please check the log file under /var/log/LAMP-On-Demand/Error_dialog_install.log\n"
					printf "$line\n"
				fi
		elif [[ $answer =~ [n|N] ]]; then
			printf "$line\n"
			printf "Exiting, have a nice day!\n"
			printf "$line\n"
			exit
		fi
	fi

}

Web_server_Installation () {		## choose which web server would you like to install
	####Variables & Function calls####
	For_The_Looks
	Root_Check
	Distro_Check
	Log_Path
	Dialog_Check
	# local PS3="Please select the web server that you would like to install and press enters: "
	####Variables & Function calls####

	## prompt the user with a menu to select whether to install apache or nginx web server
	web_server=$(dialog --title "LAMP-On-Demand" \
	--menu "Please choose web server to install:" 15 55 5 \
	1 "Apache" \
	2 "Ngnix" \
	3 "Exit from the path to LAMP stack :(")

	case $web_server in
		Apache)
			if [[ $Distro_Val =~ "centos" ]]; then
				yum install httpd -y 2>> $web_install_stderr_log >> $web_install_stdout_log
			elif [[ $Distro_Val =~ "debian" ]]; then
				apt-get install apache2 -y 2>> $web_install_stderr_log >> $web_install_stdout_log
			fi
			if [[ $? -eq 0 ]]; then
				printf "$line\n"
				printf "Apache installation completed successfully, have a nice day!\n"
				printf "$line\n"
				web_server=apache
			else
				printf "$line\n"
				printf "Something went wrong during Apache installation\n"
				printf "Please check the log file under $web_install_stderr_log\n"
				printf "$line\n"
			fi
			;;
		Ngnix)
			if [[ $Distro_Val =~ "centos" ]]; then
				yum --enablerepo=epel -y install nginx 2>> $web_install_stderr_log >> $web_install_stdout_log
			elif [[ $Distro_Val =~ "debian" ]]; then
				apt-get install nginx -y 2>> $web_install_stderr_log >> $web_install_stdout_log
			fi
			if [[ $? -eq 0 ]]; then
				printf "$line\n"
				printf "Ngnix installation completed successfully, have a nice day!\n"
				printf "$line\n"
				web_server=nginx
			else
				printf "$line\n"
				printf "Something went wrong during Ngnix installation\n"
				printf "Please check the log file under $web_install_stderr_log\n"
				printf "$line\n"
			fi
			;;
		"Exit from the path to LAMP stack :(")
		printf "$line\n"
		printf "Exit - I hope you feel safe now\n"
		printf "$line\n"
		exit 0
		;;
		esac

	}

Web_Server_Configuration () {		## start the web server's service
	Web_server_Installation

	if [[ $web_server =~ "Apache" ]]; then
		if [[ $Distro_Val =~ "centos" ]]; then
			systemctl enable httpd 2>> $web_service_stderr_log >> $web_service_stdout_log
			if [[ $? -eq 0 ]]; then
				:
			else
				printf "$line\n"
				printf "Something went wrong while enabling the service\n"
				printf "Please check the log file under $web_service_stderr_log\n"
				printf "$line\n"
				exit
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
				exit
			fi
			systemctl restart apache2 2>> $web_service_stderr_log >> $web_service_stdout_log
			apache_exit=$?
		fi
		if [[ $httpd_exit == 0 || $apache_exit == 0  ]] ;then
			printf "$line\n"
			printf "Apache web server is up and running!"
			printf "$line\n"
		else
			printf "$line\n"
			printf "Something went wrong while enabling the service\n"
			printf "Please check the log file under $web_service_stderr_log\n"
			printf "$line\n"
			exit
		fi
	elif [[ $web_server =~ "Nginx" ]]; then
		systemctl enable nginx 2>> $web_service_stderr_log >> $web_service_stdout_log
		if [[ $? -eq 0 ]] ;then
			:
		else
			printf "$line\n"
			printf "Something went wrong while enabling the service\n"
			printf "Please check the log file under $web_service_stderr_log\n"
			printf "$line\n"
			exit
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
			exit
		fi
	fi
}
Web_Server_Configuration
