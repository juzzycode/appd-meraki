#!/bin/bash

p=`dirname $(realpath $0)`

. $p/config.sh
cd $p

#this is the result
# [{"name":"","serial":"XXXX-XXXX-XXXX","mac":"98:XX:XX:XX:XX:XX","publicIp":"4.5.8.9","networkId":"L_12344234234234","status":"online","lastReportedAt":"2020-11-05T21:20:53.905000Z","lanIp":"192.168.0.8","gateway":"192.168.0.3","ipType":"dhcp","primaryDns":"192.168.0.6","secondaryDns":null}]

if [ -f network.config ]; then
	. network.config
fi

function load_networks {

	cat > network.config <<EOF
# This file was automatically generated by $0
# DO NOT MANUALLY EDIT
# `date`

unset netNames
declare -A netNAmes
EOF

x=`curl -s --location --request GET "https://api.meraki.com/api/v1/organizations/$ORG_ID/networks" --header "X-Cisco-Meraki-API-Key: $API_KEY"`

echo $x |jq -r '.[] | "\(.id) \(.name)"' | while read nid nname; do 
        cat >> network.config <<EOF
netNAmes[$nid]="$nname"
EOF

done

}

while true; do
	x=`curl -s --location --request GET "https://api.meraki.com/api/v1/organizations/$ORG_ID/devices/statuses" --header "X-Cisco-Meraki-API-Key: $API_KEY"`

	echo $x |jq -r '.[] | "\(.networkId) \(.name) \(.mac) \(.status)"' | while read n name m s; do 

		# if there's a Name set, use that, otherwise use mac. in either case, strip colons
		if [[ $name == "" ]];then deviceName=`echo $m | sed 's/://g'`; else deviceName=`echo $name | sed 's/://g'`; fi
		#convert status to a number
		if [[ "$s" == "online" ]] ; then s=1; else s=0; fi
		#if we have the network name cached, use that, otherwise go fetch the new network change.
		if  [[  ${netNAmes[$n]} == "" ]]; then
			load_networks
			. network.config
		fi
		#if there's a name in the lookup config, use that. otherwise use just the network id.
		if [[ ${netNAmes[$n]} != "" ]]; then
			echo "name=Custom Metrics|Meraki|Networks|${netNAmes[$n]}|$deviceName,value=$s"
		else
			echo "name=Custom Metrics|Meraki|Networks|$n|$deviceName,value=$s"
		fi
	done
	sleep 60
done
