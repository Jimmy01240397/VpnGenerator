#!/bin/bash

printhelp()
{
	echo "Usage: $0 [options]
Options:
  -h, --help                    display this help message and exit.
  -n, --servername SERVERNAME   Server name of VPN.
  -a, --addresses IP1,IP2...    IP Addresses of VPN.
  -p, --port PORT               UDP port of VPN.
  -m, --moreconfig MORECONFIG   Some additional settings of VPN." 1>&2
	exit 1
}

dirpath=$(dirname "$(readlink -f "$0")")

servername=""
addresses=""
port=""
moreconfig=""

while [ "$1" != "" ]
do
    case "$1" in
        -h|--help)
            printhelp
            ;;
        -n|--servername)
            shift
            servername=$1
            ;;
        -a|--addresses)
            shift
            addresses=$1
            ;;
        -p|--port)
            shift
            port=$1
            ;;
        -m|--moreconfig)
            shift
            moreconfig=$1
            ;;
    esac
    shift
done

if [ "$servername" == "" ] || [ "$addresses" == "" ] || [ "$port" == "" ]
then
    printhelp
fi

ansible-playbook $dirpath/roles/addwgserver/setup.yml -e "{\"servername\":\"$servername\",\"addresses\":\"$addresses\",\"serverport\":\"$port\",\"moreconfig\":\"$moreconfig\"}"
