#!/bin/bash


jq=`which jq`
res=$?
if [ $res -eq 1 ]; then 
	echo "Please install the 'jq' package"
	exit 1
fi



dir=`dirname $(realpath $0)`
cd $dir

if [ -f XXXconfig.sh ]; then
	echo "$dir/config.sh exists, remove it and try again"
	exit 1
fi

api=$API_KEY
if [[ $API_KEY == "" ]]; then
	echo "Enter your api key from Meraki dashboard under Profile: "
	read api
fi

#get org

soap=`curl -s --location --request GET 'https://api.meraki.com/api/v1/organizations' --header "X-Cisco-Meraki-API-Key: $api"`

orgid=`echo $soap | jq ".[] | .id" | head -n 1 | sed 's/"//g'`

echo "Meraki org id: $orgid"


cat > config.sh <<EOF
export API_KEY="$api"
export ORG_ID="$orgid"
EOF

echo Setup complete.
