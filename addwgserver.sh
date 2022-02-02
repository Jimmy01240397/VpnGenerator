#!/bin/bash

argnum=$#
if [ $argnum -eq 0 ]
then
        echo "use -h to get info"
        exit 0
fi

name=""
address=""
port=""
for a in $(seq 1 1 $argnum)
do
        nowarg=$1
        case "$nowarg" in
                -h)
                        echo "addwgserver.sh -n <ServerConfName> -i <interface address> -p <server port>"
                        exit 0
                        ;;
                -n)
                        shift
                        name=$1
                        ;;
                -i)
                        shift
                        address=$1
                        ;;
                -p)
                        shift
                        port=$1
                        ;;
                *)
                        if [ "$nowarg" = "" ]
                        then
                                break
                        fi
                        echo "bad arg..."
                        exit 0
                        ;;
        esac
        shift
done

if [ "$name" = "" ] || [ "$address" = "" ] || [ "$port" = "" ]
then
    echo "Missing arg..."
    exit 0
fi

echo "[Interface]" > /etc/wireguard/$name.conf
echo "Address = $address" >> /etc/wireguard/$name.conf
echo "PrivateKey = $(wg genkey)" >> /etc/wireguard/$name.conf
echo "ListenPort = $port" >> /etc/wireguard/$name.conf
echo "" >> /etc/wireguard/$name.conf
