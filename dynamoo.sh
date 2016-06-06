#!/bin/bash

ZONE=Z28W77SPATO8SR

ip=$(curl -s http://ipecho.net/plain)
tmpfile=$(mktemp /tmp/r53temp.XXXXXXXX)

if [ -z "$1" ]; then
  hostname=$(hostname | cut -f 1 -d .)
else
  hostname="$1"
fi

echo $ip $hostname

cat > $tmpfile <<MOOSE
{
  "Comment": "$ip $hostname",
  "Changes": [
      {
          "Action": "UPSERT",
          "ResourceRecordSet": {
              "TTL": 60,
              "Name": "$hostname",
              "Type": "A",
              "ResourceRecords": [ { "Value": "$ip" } ]
          }
      }
  ]
}
MOOSE

aws route53 change-resource-record-sets --hosted-zone-id="$ZONE" --change-batch file://"$tmpfile"
rm "$tmpfile"
