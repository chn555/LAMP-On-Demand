#!/bin/bash


####Function####

For_The_Looks () {		## for decoration output only
	  line=#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!
}

Root_Check () {		## checks that the script runs as root
	if [[ $EUID -eq 0 ]] ;then
		:
	else
		zenity --error --text "please run the script as root" --width 200
		exit
	fi
}


Distro_Check () {		## checking the environment the user is currenttly running on to determine which settings should be applied

	cat /etc/*-release |grep ID |cut  -d "=" -f "2" |egrep "^arch$|^manjaro$" &> /dev/null

	if [[ $? -eq 0 ]] ;then
	  	Distro_Val="arch"
	else
	  	:
	fi

	  cat /etc/*-release |grep ID |cut  -d "=" -f "2" |egrep "^debian$|^\"Ubuntu\"$" &> /dev/null

	  if [[ $? -eq 0 ]] ;then
	    	Distro_Val="debian"
	  else
	    	:
	  fi

	cat /etc/*-release |grep ID |cut  -d "=" -f "2" |egrep "^\"centos\"$|^\"fedora\"$" &> /dev/null

	if [[ $? -eq 0 ]] ;then
	   	Distro_Val="centos"
	else
		:
	fi
}


Web_server_Installation () {		## choose which web server would you like to install

####Variables & Function calls####
	For_The_Looks
	Distro_Val
	Root_Check
	web_stderr_log=/log/LAMPConf/Error_websrv_install.log
	web_stdout_log=/log/LAMPConf/websrv_install.log
	web_srv=(Apache Ngnix Exit)
	local PS3="Please select the web server that you would like to install and press enters: "
####Variables & Function calls####


## prompt the user with a menu to select whether to install apache or nginx web server
select opt in ${web_srv[@]} ;do
	case $opt in
		Apache)
			if [[ $Distro_Val =~ "centos" ]] ;then
				yum install httpd -y 2> $web_stderr_log > $web_stdout_log
			elif [[ $Distro_Val =~ "debian" ]]; then
				apt-get install apache2 -y 2> $web_stderr_log > $web_stdout_log
			fi
			if [[ $? -eq 0 ]] ;then
				printf "$line\n"
				printf "Apache installation completed successfully, have a nice day!\n"
				printf "$line\n"
				web_server=apache
			else
				printf "$line\n"
				printf "Something went wrong during Apache installation\n"
				printf "Please check the log file under /log/LAMPConf/Error_websrv_install.log"
				printf "$line\n"
			fi
			;;
		Ngnix)
			if [[ $Distro_Val =~ "centos" ]] ;then
				yum --enablerepo=epel -y install nginx 2> web_stderr_log > web_stdout_log
			elif [[ $Distro_Val =~ "debian" ]] ;then
				apt-get install nginx -y
			fi
			if [[ $? -eq 0 ]] ;then
				printf "$line\n"
				printf "Ngnix installation completed successfully, have a nice day!\n"
				printf "$line\n"
				web_server=nginx
			else
				printf "$line\n"
				printf "Something went wrong during Ngnix installation\n"
				printf "Please check the log file under /log/LAMPConf/Error_websrv_install.log"
				printf "$line\n"
			fi
			;;
		Exit)
		printf "$line\n"
		printf "Exit -I hope you feel safe now\n"
		prinf "$line\n"
		;;
		esac
	done
}

Web_Server_Configuration () {

	if [[ $web_server =~ "apache" ]] ;then
		systemctl restart h

}

Distro_Check
Root_Check
Web_server_Installation
