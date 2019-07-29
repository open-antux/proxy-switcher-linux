#!/bin/bash

function start {
	export {http,https,ftp,rsync}_proxy="http://$ipaddr:$port"
	export no_proxy="localhost, 127.0.0.1"

	#Setup proxy with socks
	cat /etc/tsocks.conf &> /dev/null
	if [[ $? != 1 ]]
	then
		mv /etc/tsocks.conf /etc/tsocks.conf.back
		echo "server = $ipaddr" > /etc/tsocks.conf
		echo "server_port = $port" >> /etc/tsocks.conf
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
	fi
}

function stop {
	unset {http,https,ftp,rsync,no}_proxy

	#Restore /etc/tsocks.conf
	cat /etc/tsocks.conf.back &> /dev/null
	if [[ $? != 1 ]]
	then
		rm /etc/tsocks.conf
		mv /etc/tsocks.conf.back /etc/tsocks.conf
	fi

	#Restore gsettings
	if [[ $XDG_CURRENT_DESKTOP == "GNOME" ]]
	then		
		mode=$(echo $(gsettings get org.gnome.system.proxy mode))
		if [[ $mode == 'manual' ]]
		then
			gsettings set org.gnome.system.proxy mode 'none'
		fi
	fi
}

if [[ $1 != "" ]]
then
	stop #Stop all proxy
	ipaddr=$1

	if [[ $2 == "" ]]
	then
		port="8080"
	else
		port=$2
	fi

	start #Start to setup proxy

else
	stop
fi
