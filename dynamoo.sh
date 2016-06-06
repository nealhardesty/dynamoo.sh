#!/bin/bash

ZONE=Z28W77SPATO8SR

if [ ! #(which aws) ]; then
  echo "AWS CLI is not installed.  Installing now..."
  echo
  pushd /var/tmp
  rm -rf awscli-bundle.zip awscli-bundle
  curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip" || die "could not download awscli"
  unzip awscli-bundle.zip || die "could not unzip awscli"
  sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
  popd
fi

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
