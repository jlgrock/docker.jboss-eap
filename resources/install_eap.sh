#!/bin/sh

# Load the current versions
. ./loadenv.sh

EAP_HOME=/opt/jboss/jboss-eap

# Unzip EAP to the version-generic home directory
echo "unzipping files..."
unzip -q ./jboss-eap-$JBOSS_EAP*.zip
rm -rf *.zip
mv /opt/jboss/jboss-eap* $EAP_HOME

# Put adjusted configuration files into the appropriate directory.  Some will be adjusted at startup
cp -rf host*.xml $EAP_HOME/domain/configuration/
rm -rf host*.xml

# Put all wars into standalone deployments.  This should not be used for the core image, but 
# more for extension
cp -rf *.war $EAP_HOME/standalone/deployments/
rm -rf *.war

# Copy the activeMQ connector and activate it
mv activemq-rar*.rar $EAP_HOME/standalone/deployments/activemq-rar.rar

# Move the startup script to EAP_HOME
mv startup.sh $EAP_HOME

