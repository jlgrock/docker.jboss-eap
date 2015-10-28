#!/bin/sh

# Load the current versions
. ./loadenv.sh

EAP_HOME=/opt/jboss/jboss-eap

echo "unzipping files..."
unzip -q ./jboss-eap-$JBOSS_EAP*.zip
rm -rf *.zip
mv /opt/jboss/jboss-eap* $EAP_HOME

mv *.war $EAP_HOME/standalone/deployments/

sed -i 's/<deployment-scanner path="deployments" relative-to="jboss.server.base.dir" scan-interval="0"\/>/<deployment-scanner path="deployments" relative-to="jboss.server.base.dir" scan-interval="0" auto-deploy-zipped="true"\/>/' $EAP_HOME/standalone/configuration/standalone-full-ha.xml
