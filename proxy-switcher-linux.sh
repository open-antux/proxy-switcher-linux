#!/bin/bash

function start {
	export {http,https,ftp,rsync}_proxy="http://$ipaddr:$port"
	#export https_proxy="http://$ipaddr:$port"
	#export rsync_proxy="http://$ipaddr:$port"
	#export ftp_proxy="http://$ipaddr:$port"
	export no_proxy="localhost, 127.0.0.1"

	echo -e '\033[1;32mExported http, https, ftp, rsync proxy variable'

	#Setup proxy with socks
	cat /etc/tsocks.conf &> /dev/null
	if [[ $? != 1 ]]
	then
		mv /etc/tsocks.conf /etc/tsocks.conf.back
		echo "server = $ipaddr" > /etc/tsocks.conf
		echo "server_port = $port" >> /etc/tsocks.conf

		echo -e '\033[1;32mSetted server and server_port on tsocks.conf file'
	fi

	#Setup proxy with gsettings
	if [[ $XDG_CURRENT_DESKTOP == "GNOME" ]]
	then
		gsettings set org.gnome.system.proxy mode 'manual'

		gsettings set org.gnome.system.proxy.http host "$ipaddr"
		gsettings set org.gnome.system.proxy.https host "$ipaddr"
		gsettings set org.gnome.system.proxy.ftp host "$ipaddr"

		gsettings set org.gnome.system.proxy.http port "$port"
		gsettings set org.gnome.system.proxy.https port "$port"
		gsettings set org.gnome.system.proxy.ftp port "$port"

		gsettings set org.gnome.system.proxy ignore-hosts "['localhost', '127.0.0.0/8', '10.0.0.0/8', '192.168.0.0/16', '172.16.0.0/12' , '*.localdomain.com' ]"

		echo -e '\033[1;32mSetted proxy with GNOME'
	fi
}

function stop {
	#Restore /etc/tsocks.conf
	cat /etc/tsocks.conf.back &> /dev/null
	if [[ $? != 1 ]]
	then
		rm /etc/tsocks.conf
		mv /etc/tsocks.conf.back /etc/tsocks.conf

		echo -e '\033[1;32mRestored tsocks.conf file'
	fi

	#Restore gsettings
	if [[ $XDG_CURRENT_DESKTOP == "GNOME" ]]
	then
		mode=$(gsettings get org.gnome.system.proxy mode | sed "s/'//g")
		if [[ "$mode" == "manual" ]]
		then
			gsettings set org.gnome.system.proxy mode 'none'
			echo -e '\033[1;32mRestored GNOME settings'
		else
			echo -e '\033[1;31mError to restoring GNOME settings'
		fi
     elif [[ "$(echo ${http,https,ftp,rsync,no}_proxy)" != "" ]]
     then
     	echo -e '\033[1;31mUnset the variables unsuccessfully'
     else
          unset {http,https,ftp,rsync}_proxy
          echo -e '\033[1;32mUnset the variables successfully'
     fi 2> /dev/null
}

ipaddr=$1
if [[ $(echo ${ipaddr} | grep -E -o "([0-9]{1,3}\.){3}[0-9]{1,3}" ) != "" ]]
then
	stop #Stop all proxy
	
	if [[ $2 == "" ]]
	then
		port="8080"
	else
		port=$2
	fi

	start #Start to setup proxy

elif [[ $1 == "stop" ]]; then
	stop
else
     echo -e '\033[1;31mError: Digit a valid proxy server'
fi
