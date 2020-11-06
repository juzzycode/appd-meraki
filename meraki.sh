#!/bin/bash

p=`dirname $(realpath $0)`

. $p/config.sh

#this is the result
# [{"name":"","serial":"Q3AB-6PSK-2KD2","mac":"98:18:88:fe:6b:b4","publicIp":"24.158.108.92","networkId":"L_615304299089505647","status":"online","lastReportedAt":"2020-11-05T21:20:53.905000Z","lanIp":"192.168.50.8","gateway":"192.168.50.3","ipType":"dhcp","primaryDns":"192.168.50.67","secondaryDns":null}]
while true; do
	x=`curl -s --location --request GET "https://api.meraki.com/api/v1/organizations/$ORG_ID/devices/statuses" --header "X-Cisco-Meraki-API-Key: $API_KEY"`

	echo $x |jq -r '.[] | "\(.mac) \(.status)"' | while read m s; do 
		newn=`echo $m | sed 's/://g'`
		if [[ "$s" == "online" ]] ; then s=1; else s=0; fi
		echo "name=Custom Metrics|MerakiDevices|$newn,value=$s"
	done
	sleep 60
done
