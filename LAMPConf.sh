#!/bin/bash


####Function####

For_The_Looks () {		## for decoration output only
	  line=#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!#!
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

	cat /etc/*-release |grep ID |cut  -d "=" -f "2" |egrep "^arch$|^manjaro$"

	if [[ $? -eq 0 ]] ;then
	  	Distro_Val="arch"
	else
	  	:
	fi

	  cat /etc/*-release |grep ID |cut  -d "=" -f "2" |egrep "^debian$|^\"Ubuntu\"$"

	  if [[ $? -eq 0 ]] ;then
	    	Distro_Val="debian"
	  else
	    	:
	  fi

	cat /etc/*-release |grep ID |cut  -d "=" -f "2" |egrep "^\"centos\"$|^\"fedora\"$"

	if [[ $? -eq 0 ]] ;then
	   	Distro_Val="centos"
	else
		:
	fi
}


Web_server_Installation () {		## choose which web server would you like to install

####Variables####
	For_The_Looks
	web_stderr_log=/log/LAMPConf/Error_websrv_install.log
	web_stdout_log=/log/LAMPConf/websrv_install.log
	web_srv=(Apache Ngnix)
	local PS3="Please select the web server that you would like to install: "
####Variables####

	## prompt the user with a menu to select whether to install apache or nginx web server
	select opt in ${web_srv[@]} ;do
		case opt in
			Apache)
				yum install httpd -y 2> web_stderr_log > web_stdout_log
				if [[ $? -eq 0 ]] ;then
					printf "$line\n"
					printf "Apache installation completed successfully\n"
					printf "$line\n"
				else
					printf "$line\n"
					printf "Something went wrong during Apache installation\n"
					printf "Please check the log file under /log/LAMPConf/Error_websrv_install.log"
					printf "$line\n"
				fi
				;;
			Ngnix)
				yum --enablerepo=epel -y install nginx
				if [[ $? -eq 0 ]] ;then
					printf "$line\n"
					printf "Ngnix installation completed successfully\n"
					printf "$line\n"
				else
					printf "$line\n"
					printf "Something went wrong during Ngnix installation\n"
					printf "Please check the log file under /log/LAMPConf/Error_websrv_install.log"
					printf "$line\n"
				fi
				;;
			esac
		done
}
Distro_Check
Root_Check
Web_server_Installation
