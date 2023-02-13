#!/bin/bash

printhelp()
{
	echo "Usage: $0 [options]
Options:
  -h, --help                    display this help message and exit.
  -n, --servername SERVERNAME   Server name of VPN." 1>&2
	exit 1
}

dirpath=$(dirname "$0")

servername=""

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
    esac
    shift
done

if [ "$servername" == "" ]
then
    printhelp
fi

ansible-playbook $dirpath/roles/delwgserver/setup.yml -e "{\"servername\":\"$servername\"}"
