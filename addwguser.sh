#!/bin/bash


argnum=$#
if [ $argnum -eq 0 ]
then
	echo "Missing arg..."
	exit 0
fi

user=""
serverconf=""
fqdn=""
clientconfdir="client"
for a in $(seq 1 1 $argnum)
do
        nowarg=$1
        case "$nowarg" in
	            -h)
                        echo "addwguser.sh -s <ServerConfPath> -u <username> -f <fqdn> -r <clientroute> -a <clientvpnaddress> -d <clientconfdir> -ns <nameserver>"
                        exit 0
                        ;;
                -s)
                        shift
                        serverconf=$1
                        ;;
                -a)
                        shift
                        nowip=$1
                        ;;
                -u)
                        shift
                        user=$1
                        ;;
                -f)
                        shift
                        fqdn=$1
                        ;;
                -d)
                        shift
                        if [ "$1" != "" ]
                        then
                            clientconfdir=$1
                        fi
                        ;;
                -ns)
                        shift
                        nameserver=$1
                        ;;
        		-r)
                        shift
                        route=$1
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

if [ "$serverconf" = "" ] || [ "$user" = "" ] || [ "$fqdn" = "" ] || [ "$route" = "" ]
then
	echo "Missing arg..."
	exit 0
fi

if [ "$(grep "# $user" $serverconf)" != "" ]
then
    echo "User exist"
    exit 0
fi

function atoi
{
	#Returns the integer representation of an IP arg, passed in ascii dotted-decimal notation (x.x.x.x)
	IP=$1; IPNUM=0
	for (( i=0 ; i<4 ; ++i )); do
		((IPNUM+=${IP%%.*}*$((256**$((3-${i}))))))
		IP=${IP#*.}
	done
	echo $IPNUM 
} 

function itoa
{
	#returns the dotted-decimal ascii form of an IP arg passed in integer format
	echo -n $(($(($(($((${1}/256))/256))/256))%256)).
	echo -n $(($(($((${1}/256))/256))%256)).
	echo -n $(($((${1}/256))%256)).
	echo $((${1}%256)) 
}

nowip=$(atoi $nowip)

if [ $nowip -eq 0 ]
then
    nowip=""
fi

if [ "$nowip" != "" ]
then
    if [ "$(grep AllowedIPs $serverconf | grep $(itoa $nowip))" != "" ]
    then
        nowip=""
    fi
fi

nowmask=`grep Address $serverconf | grep -oP '(?<=Address\s=\s)\d+(\.\d+){3}\K/\d+' | tail -n 1`
nowpsk=`wg genpsk`
nowprk=`wg genkey`
nowpuk=`echo $nowprk | wg pubkey`
serverport=`grep ListenPort $serverconf | grep -oP '(?<=ListenPort\s=\s)\d+' | tail -n 1`
serverpuk=`grep PrivateKey $serverconf | grep -oP '(?<=PrivateKey\s=\s).*' | tail -n 1 | wg pubkey`

if [ "$nowip" == "" ]
then
    nowip=$(grep AllowedIPs $serverconf | grep -oP '(?<=AllowedIPs\s=\s)\d+(\.\d+){3}' | tail -n 1)

    if [ "$nowip" == "" ]
    then
        nowip=$(($(atoi $(grep Address $serverconf | grep -oP '(?<=Address\s=\s)\d+(\.\d+){3}' | tail -n 1))&$((2#$(printf '%*s' "$(echo $nowmask | cut -c 2-)" | sed "s/ /1/g")$(printf "%0$((32-$(echo $nowmask | cut -c 2-)))d" 0)))))
    else
        nowip=$(atoi $nowip)
    fi

    ((nowip++))

    if [ $nowip -eq $(atoi $(grep Address $serverconf | grep -oP '(?<=Address\s=\s)\d+(\.\d+){3}' | tail -n 1)) ]
    then
        ((nowip++))
    fi
fi

echo "" >> $serverconf
echo [Peer] >> $serverconf
echo "# $user" >> $serverconf
echo "AllowedIPs = $(itoa $nowip)/32" >> $serverconf
echo "PreSharedKey = $nowpsk" >> $serverconf
echo "PublicKey = $nowpuk" >> $serverconf



echo [Interface] > /etc/wireguard/$clientconfdir/$user.conf
echo "Address = $(itoa $nowip)$nowmask" >> /etc/wireguard/$clientconfdir/$user.conf
echo "PrivateKey = $nowprk" >> /etc/wireguard/$clientconfdir/$user.conf
if [ "$nameserver" != "" ]
then
    echo "DNS = $nameserver" >> /etc/wireguard/$clientconfdir/$user.conf
fi
echo "" >> /etc/wireguard/$clientconfdir/$user.conf
echo [Peer] >> /etc/wireguard/$clientconfdir/$user.conf
echo "AllowedIPs = $route" >> /etc/wireguard/$clientconfdir/$user.conf
echo "Endpoint = $fqdn:$serverport" >> /etc/wireguard/$clientconfdir/$user.conf
echo "PreSharedKey = $nowpsk" >> /etc/wireguard/$clientconfdir/$user.conf
echo "PublicKey = $serverpuk" >> /etc/wireguard/$clientconfdir/$user.conf
echo "PersistentKeepalive = 25" >> /etc/wireguard/$clientconfdir/$user.conf


sed '/Address/d' $serverconf | sed '/PostUp/d' | sed '/PostDown/d' > /tmp/wgconf.conf
wg syncconf $(echo $serverconf | grep -oP '[^/]*(?=\.conf)') /tmp/wgconf.conf
rm /tmp/wgconf.conf

qrencode -t ansiutf8 < /etc/wireguard/$clientconfdir/$user.conf
