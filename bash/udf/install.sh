#!/bin/bash
mkdir -p /config/cloud
cd /config/cloud

curl -OL https://raw.githubusercontent.com/F5Networks/f5-cloud-libs-aws/v1.6.0/dist/f5-cloud-libs-aws.tar.gz
curl -OL https://raw.githubusercontent.com/F5Networks/f5-cloud-libs/v3.6.2/dist/f5-cloud-libs.tar.gz
mkdir -p /config/cloud/aws/node_modules
echo expanding f5-cloud-libs.tar.gz
tar xvfz /config/cloud/f5-cloud-libs.tar.gz -C /config/cloud/aws/node_modules
echo installing dependencies
tar xvfz /config/cloud/f5-cloud-libs-aws.tar.gz -C /config/cloud/aws/node_modules/f5-cloud-libs/node_modules
echo cloud libs install complete
touch /config/cloud/cloudLibsReady
echo -e "admin\n$2\n" | tmsh modify /auth password $2
echo "$2" > /config/cloud/aws/.adminPassword
/usr/local/bin/SOAPLicenseClient --basekey $1

