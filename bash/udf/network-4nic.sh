#!/bin/bash
# 
# 4 NIC
#
GATEWAY_MAC=`ifconfig eth1 | egrep HWaddr | awk '{print tolower($5)}'`; 
GATEWAY_CIDR_BLOCK=`curl -s -f --retry 20 http://169.254.169.254/latest/meta-data/network/interfaces/macs/${GATEWAY_MAC}/subnet-ipv4-cidr-block`;
GATEWAY_NET=${GATEWAY_CIDR_BLOCK%/*};
GATEWAY_PREFIX=${GATEWAY_CIDR_BLOCK#*/};
GATEWAY=`echo ${GATEWAY_NET} | awk -F. '{ print $1"."$2"."$3"."$4+1 }'`;
EXTERNAL_SELF=`curl -s -f --retry 20 http://169.254.169.254/latest/meta-data/network/interfaces/macs/${GATEWAY_MAC}/local-ipv4s/|head -1`;

GATEWAY_MAC2=`ifconfig eth2 | egrep HWaddr | awk '{print tolower($5)}'`;
GATEWAY_CIDR_BLOCK2=`curl -s -f --retry 20 http://169.254.169.254/latest/meta-data/network/interfaces/macs/${GATEWAY_MAC2}/subnet-ipv4-cidr-block`;
GATEWAY_PREFIX2=${GATEWAY_CIDR_BLOCK2#*/};
INTERNAL_SELF2=`curl -s -f --retry 20 http://169.254.169.254/latest/meta-data/network/interfaces/macs/${GATEWAY_MAC2}/local-ipv4s/|head -1`;

GATEWAY_MAC3=`ifconfig eth3 | egrep HWaddr | awk '{print tolower($5)}'`;
GATEWAY_CIDR_BLOCK3=`curl -s -f --retry 20 http://169.254.169.254/latest/meta-data/network/interfaces/macs/${GATEWAY_MAC3}/subnet-ipv4-cidr-block`;
GATEWAY_PREFIX3=${GATEWAY_CIDR_BLOCK3#*/};
INTERNAL_SELF3=`curl -s -f --retry 20 http://169.254.169.254/latest/meta-data/network/interfaces/macs/${GATEWAY_MAC3}/local-ipv4s/|head -1`;

f5-rest-node /config/cloud/aws/node_modules/f5-cloud-libs/scripts/network.js \
     --host localhost \
     --user admin \
     --password-url file:///config/cloud/aws/.adminPassword \
     --log-level debug \
     --vlan name:external,nic:1.1 \
     --default-gw ${GATEWAY} \
     --self-ip name:external-self,address:${EXTERNAL_SELF}/${GATEWAY_PREFIX},vlan:external,allow:tcp:4353 \
     --vlan name:internal,nic:1.2 \
     --self-ip name:internal-self,address:${INTERNAL_SELF2}/${GATEWAY_PREFIX2},vlan:internal 
     --vlan name:ha,nic:1.3 \
     --self-ip name:ha-self,address:${INTERNAL_SELF3}/${GATEWAY_PREFIX3},vlan:ha
