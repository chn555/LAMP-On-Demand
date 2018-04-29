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
  select $Entry in $Main_Menu_Options
  	if [[  $Entry == "Web_Server" ]]; then
  		Web_Server_Installation
  		Web_Server_Configuration
  	elif [[ " $Entry == "DataBase_Server" ]]; then
  		Sql_Server_Installation
  		Sql_Server_Configuration
  	elif [[  $Entry == "Exit" ]]; then
  		printf "\nExit - I hope you feel safe now."
  		exit 0
  	fi
  }

Root_Check
Distro_Check
Main_Menu
