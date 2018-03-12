#!/bin/bash
#
# 2 NIC
GATEWAY_MAC=`ifconfig eth1 | egrep HWaddr | awk '{print tolower($5)}'`; 

GATEWAY_CIDR_BLOCK=`curl --interface mgmt -s -f --retry 20 http://169.254.169.254/latest/meta-data/network/interfaces/macs/${GATEWAY_MAC}/subnet-ipv4-cidr-block`;
GATEWAY_NET=${GATEWAY_CIDR_BLOCK%/*};
GATEWAY_PREFIX=${GATEWAY_CIDR_BLOCK#*/};
GATEWAY=`echo ${GATEWAY_NET} | awk -F. '{ print $1"."$2"."$3"."$4+1 }'`;
EXTERNAL_SELF=`curl --interface mgmt -s -f --retry 20 http://169.254.169.254/latest/meta-data/network/interfaces/macs/${GATEWAY_MAC}/local-ipv4s/|head -1`;

f5-rest-node /config/cloud/aws/node_modules/f5-cloud-libs/scripts/network.js \
     --host localhost \
     --user admin \
     --password-url file:///config/cloud/aws/.adminPassword \
     --log-level debug \
     --vlan name:external,nic:1.1 \
     --default-gw ${GATEWAY} \
     --self-ip name:external-self,address:${EXTERNAL_SELF}/${GATEWAY_PREFIX},vlan:external
