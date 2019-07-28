#!/bin/bash

function start {
	export {http,https,ftp,rsync}_proxy="http://$ipaddr:$port"
	export no_proxy="localhost, 127.0.0.1"
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
