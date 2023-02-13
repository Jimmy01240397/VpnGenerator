#!/bin/bash

printhelp()
{
	echo "Usage: $0 [options]
Options:
  -h, --help                                    display this help message and exit.
  -s, --servername SERVERNAME                   Server name of VPN server.
  -u, --username USERNAME                       Username of VPN client.
  -d, --clientconfdir CLIENTCONFIGDIR           Directory for VPN client config. (default is 'client')" 1>&2
	exit 1
}

dirpath=$(dirname "$0")

servername=""
username=""
clientconfdir=""

while [ "$1" != "" ]
do
    case "$1" in
        -h|--help)
            printhelp
            ;;
        -s|--servername)
            shift
            servername=$1
            ;;
        -u|--username)
            shift
            username=$1
            ;;
        -d|--clientconfdir)
            shift
            clientconfdir=$1
            ;;
    esac
    shift
done

if [ "$servername" == "" ] || [ "$username" == "" ]
then
    printhelp
fi

ansible-playbook $dirpath/roles/delwguser/setup.yml -e "{\"servername\":\"$servername\",\"username\":\"$username\",\"clientconfigdir\":\"$clientconfdir\"}"
