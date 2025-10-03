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

timestamp=$(date -d "$last" +%s)
now=$(date +%s)

# Calculate difference in seconds
diff=$(( $(date +%s) - $(date -d "$last" +%s) ))

if [ $diff -lt 3600 ]; then
  last_ago="$(( diff / 60 )) minutes ago"
elif [ $diff -lt 86400 ]; then
  last_ago="$(( diff / 3600 )) hours ago"
else
  last_ago="$(( diff / 86400 )) days ago"
fi


status="ok" && message=""
[ $errors -gt 500 ] && status="warning" && message="errors=$errors";
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
        "m1":"last=$last_ago",
        "m2":"",
        "m3":"",
        "url":"$ZG_ALIGNMENT_NODE_SERVICE_IP",
        "url1":"",
        "url2":"",
        "wallet":"$wallet"    
  }
}
EOF

cat $json | jq
