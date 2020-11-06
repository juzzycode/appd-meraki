#!/bin/bash

p=`dirname $(realpath $0)`

. $p/config.sh

#this is the result
# [{"name":"","serial":"XXXX-XXXX-XXXX","mac":"98:XX:XX:XX:XX:XX","publicIp":"4.5.8.9","networkId":"L_12344234234234","status":"online","lastReportedAt":"2020-11-05T21:20:53.905000Z","lanIp":"192.168.0.8","gateway":"192.168.0.3","ipType":"dhcp","primaryDns":"192.168.50.6","secondaryDns":null}]
while true; do
	x=`curl -s --location --request GET "https://api.meraki.com/api/v1/organizations/$ORG_ID/devices/statuses" --header "X-Cisco-Meraki-API-Key: $API_KEY"`

	echo $x |jq -r '.[] | "\(.mac) \(.status)"' | while read m s; do 
		newn=`echo $m | sed 's/://g'`
		if [[ "$s" == "online" ]] ; then s=1; else s=0; fi
		echo "name=Custom Metrics|MerakiDevices|$newn,value=$s"
	done
	sleep 60
done
