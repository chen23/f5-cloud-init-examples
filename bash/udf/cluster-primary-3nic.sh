#!/bin/bash

HOSTNAME=`curl -s -f --retry 20 http://169.254.169.254/latest/meta-data/hostname`;

GATEWAY_MAC2=`ifconfig eth2 | egrep HWaddr | awk '{print tolower($5)}'`;
INTERNAL_SELF=`curl -s -f --retry 20 http://169.254.169.254/latest/meta-data/network/interfaces/macs/${GATEWAY_MAC2}/local-ipv4s/|head -1`;

echo  f5-rest-node /config/cloud/aws/node_modules/f5-cloud-libs/scripts/cluster.js \
     --host localhost \
     --user admin \
     --password-url file:///config/cloud/aws/.adminPassword \
     --log-level debug \
     --config-sync-ip ${INTERNAL_SELF} \
     --create-group \
     --device-group Sync \
     --sync-type sync-failover \
     --network-failover \
     --device ${HOSTNAME}
tmsh modify sys db dhclient.mgmt { value disable }
tmsh modify cm device ${HOSTNAME} unicast-address { { effective-ip ${INTERNAL_SELF} effective-port 1026 ip ${INTERNAL_SELF} } }
