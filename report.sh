#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
folder=$(echo $path | awk -F/ '{print $NF}')
json=/root/logs/report-$folder
source /root/.bash_profile
source $path/env

version=$()
service=$(sudo systemctl status $folder --no-pager | grep "active (running)" | wc -l)
errors=$(journalctl -u $folder.service --since "1 hour ago" --no-hostname -o cat | grep -c -E "rror|ERR")
last=$(journalctl -u $folder.service --no-hostname -o cat | grep -E "Received CheckNodeOperation request" | tail -1 | cut -d "\"" -f 2)
wallet=$(journalctl -u $folder.service --no-hostname -o cat | grep -E "Verified identity result" | tail -1 | awk -F "address=" '{print $NF}')
response=$(curl $(echo $ZG_ALIGNMENT_NODE_SERVICE_IP | sed 's/\(.*\):.*/\1:80/'))

# Calculate difference in seconds
[ $last ] && diff=$(( $(date +%s) - $(date -d "$last" +%s) )) || diff=0

if [ $diff -eq 0 ]; then
  last_ago="no checkin"
elif [ $diff -lt 3600 ]; then
  last_ago="$(( diff / 60 )) minutes ago"
elif [ $diff -lt 86400 ]; then
  last_ago="$(( diff / 3600 )) hours ago"
else
  last_ago="$(( diff / 86400 )) days ago"
fi

status="ok" && message="checkin $last_ago"
[ $diff -gt 86400 ] && status="warning" && message="no checkin last 24h";
[ $diff -eq 0 ] && status="error" && message="no checkin";
[ "$response" != "OK" ] && status="error" && message="no response";
[ $errors -gt 500 ] && status="warning" && message="too many errors";
[ $service -ne 1 ] && status="error" && message="service not running";
cat >$json << EOF
{
  "updated":"$(date --utc +%FT%TZ)",
  "measurement":"report",
  "tags": {
       "id":"$folder-$ID",
       "machine":"$MACHINE",
       "grp":"node",
       "owner":"$OWNER"
  },
  "fields": {
        "chain":"Aristotle",
        "network":"mainnet",
        "version":"$version",
        "status":"$status",
        "message":"$message",
        "service":"$service",
        "errors":"$errors",
        "height":"",
        "m1":"response=$response",
        "m2":"checkin=$last_ago",
        "m3":"",
        "url":"$ZG_ALIGNMENT_NODE_SERVICE_IP",
        "url1":"",
        "url2":"",
        "wallet":"$wallet"    
  }
}
EOF

cat $json | jq
