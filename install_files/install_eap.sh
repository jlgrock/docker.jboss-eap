#!/bin/sh

# Load the current versions
. ./loadenv.sh

EAP_HOME=/opt/jboss/jboss-eap

echo "unzipping files..."
unzip -q ./jboss-eap-$JBOSS_EAP*.zip
rm -rf *.zip
mv /opt/jboss/jboss-eap* $EAP_HOME