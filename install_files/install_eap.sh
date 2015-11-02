#!/bin/sh

# Load the current versions
. ./loadenv.sh

EAP_HOME=/opt/jboss/jboss-eap

# Unzip EAP to the version-generic home directory
echo "unzipping files..."
unzip -q ./jboss-eap-$JBOSS_EAP*.zip
rm -rf *.zip
mv /opt/jboss/jboss-eap* $EAP_HOME

# Set standalone mode to auto-deploy and wars that are placed into the deploy dir,
# and put the wars in "install_files" into the deploy dir
sed -i 's/<deployment-scanner path="deployments" relative-to="jboss.server.base.dir" scan-interval="0"\/>/<deployment-scanner path="deployments" relative-to="jboss.server.base.dir" scan-interval="0" auto-deploy-zipped="true"\/>/' $EAP_HOME/standalone/configuration/standalone-full-ha.xml
mv *.war $EAP_HOME/standalone/deployments/

# Fix hard coded loopback addresses
sed -i 's/c2xhdmVfdXNlcl9wYXNzd29yZA==/YWRtaW4xMjMh/' $EAP_HOME/domain/configuration/host-slave.xml
sed -i 's/<remote host="\${jboss\.domain\.master\.address}" port="\${jboss\.domain\.master\.port:9999}" security-realm="ManagementRealm"\/>/<remote host="${jboss.domain.master.address}" port="${jboss.domain.master.port:9999}" username="admin" security-realm="ManagementRealm" \/>/' $EAP_HOME/domain/configuration/host-slave.xml

# Copy the activeMQ connector and activate it
mv activemq-rar*.rar $EAP_HOME/standalone/deployments/activemq-rar.rar

# Move the startup script to EAP_HOME
mv startup.sh $EAP_HOME

