#/bin/sh
INTERFACE=eth1
INTERFACE_MAC=`ifconfig ${INTERFACE} | egrep HWaddr | awk '{print tolower($5)}'`
VPC_CIDR_BLOCK=`curl -s -f --retry 20 http://169.254.169.254/latest/meta-data/network/interfaces/macs/${INTERFACE_MAC}/vpc-ipv4-cidr-block`
VPC_NET=${VPC_CIDR_BLOCK%/*}
NAME_SERVER=`echo ${VPC_NET} | awk -F. '{ printf "%d.%d.%d.%d", $1, $2, $3, $4+2 }'`

f5-rest-node /config/cloud/aws/node_modules/f5-cloud-libs/scripts/onboard.js \
             --log-level debug \
             --no-reboot \
             --host localhost \
             --user admin \
             --password-url file:///config/cloud/aws/.adminPassword \
             --hostname `curl -s -f --retry 20 http://169.254.169.254/latest/meta-data/hostname` \
             --ntp 0.pool.ntp.org \
             --tz UTC \
             --dns ${NAME_SERVER} 
