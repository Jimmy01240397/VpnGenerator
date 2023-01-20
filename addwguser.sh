#!/bin/bash

printhelp()
{
	echo "Usage: $0 [options]
Options:
  -h, --help                                    display this help message and exit.
  -s, --serverconfpath SERVERCONFIGPATH         Server config path of VPN server.
  -u, --username USERNAME                       Username of VPN client.
  -f, --fqdn FQDN                               Server FQDN.
  -r, --routes CLIENTROUTES1,CLIENTROUTES2...   VPN route for VPN client.
  -a, --addresses IP1,IP2...                    IP Addresses of VPN client. (optional)
  -d, --clientconfdir CLIENTCONFIGDIR           Directory for VPN client config. (default is 'client')
  -ns, --nameserver NAMESERVER                  Nameserver of VPN client. (optional)
  -m, --moreconfig MORECONFIG                   Some additional settings of VPN. (optional)" 1>&2
	exit 1
}

dirpath=$(dirname "$0")

serverconfpath=""
username=""
fqdn=""
routes=""
addresses=""
clientconfdir="client"
nameserver=""
moreconfig=""

while [ "$1" != "" ]
do
    case "$1" in
        -h|--help)
            printhelp
            ;;
        -s|--serverconfpath)
            shift
            serverconfpath=$1
            ;;
        -u|--username)
            shift
            username=$1
            ;;
        -f|--fqdn)
            shift
            fqdn=$1
            ;;
        -r|--routes)
            shift
            routes=$1
            ;;
        -a|--addresses)
            shift
            addresses=$1
            ;;
        -d|--clientconfdir)
            shift
            clientconfdir=$1
            ;;
        -ns|--nameserver)
            shift
            nameserver=$1
            ;;
        -m|--moreconfig)
            shift
            moreconfig=$1
            ;;
    esac
    shift
done

if [ "$serverconfpath" == "" ] || [ "$username" == "" ] || [ "$fqdn" == "" ] || [ "$routes" == "" ]
then
    printhelp
fi

if [ "$(readlink -f $serverconfpath)" != "" ]
then
    serverconfpath=$(readlink -f $serverconfpath)
fi

ansible-playbook $dirpath/roles/addwguser/setup.yml -e "{\"serverconfig\":\"$serverconfpath\",\"username\":\"$username\",\"fqdn\":\"$fqdn\",\"routes\":\"$routes\",\"addresses\":\"$addresses\",\"clientconfigdir\":\"$clientconfdir\",\"nameserver\":\"$nameserver\",\"moreconfig\":\"$moreconfig\"}"
