#!/bin/sh

# Load the current versions
. ./loadenv.sh

# Unzip EAP to the version-generic home directory
echo "unzipping files..."
unzip -q ./jboss-eap-$JBOSS_EAP*.zip
rm -rf *.zip
mv ./jboss-eap* $EAP_HOME

# Put adjusted configuration files into the appropriate directory.  Some will be adjusted at startup
cp -rf host*.xml $EAP_HOME/domain/configuration/
rm -rf host*.xml

# Put all wars into standalone deployments.  This should not be used for the core image, but 
# more for extension
cp -rf *.war $EAP_HOME/standalone/deployments/
rm -rf *.war

echo "export JBOSS_USER_APP_MODULES_HOME=\"/opt/app/jboss/modules/app-modules\"" >> $EAP_HOME/bin/standalone.conf
echo "export JBOSS_USER_SEC_MODULES_HOME=\"/opt/app/jboss/modules/sec-modules\"" >> $EAP_HOME/bin/standalone.conf
echo "export JBOSS_USER_DATABASES_MODULES_HOME=\"/opt/app/jboss/modules/db-modules\"" >> $EAP_HOME/bin/standalone.conf
echo "export JBOSS_MODULES_HOME=\"/opt/app/jboss/jboss-eap/modules\"" >> $EAP_HOME/bin/standalone.conf
echo "export JBOSS_MODULEPATH=\"$JBOSS_MODULES_HOME:$HBOSS_USER_APP_MODULES_HOME:$JBOSS_USER_SEC_MODULES_HOME:$JBOSS_USER_DATABASES_MODULES_HOME\"" >> $EAP_HOME/bin/standalone.conf

echo "export JBOSS_USER_APP_MODULES_HOME=\"/opt/app/jboss/modules/app-modules\"" >> $EAP_HOME/bin/domain.conf
echo "export JBOSS_USER_SEC_MODULES_HOME=\"/opt/app/jboss/modules/sec-modules\"" >> $EAP_HOME/bin/domain.conf
echo "export JBOSS_USER_DATABASES_MODULES_HOME=\"/opt/app/jboss/modules/db-modules\"" >> $EAP_HOME/bin/domain.conf
echo "export JBOSS_MODULES_HOME=\"/opt/app/jboss/jboss-eap/modules\"" >> $EAP_HOME/bin/domain.conf
echo "export JBOSS_MODULEPATH=\"$JBOSS_MODULES_HOME:$HBOSS_USER_APP_MODULES_HOME:$JBOSS_USER_SEC_MODULES_HOME:$JBOSS_USER_DATABASES_MODULES_HOME\"" >> $EAP_HOME/bin/domain.conf

# Copy the activeMQ connector and activate it
mv activemq-rar*.rar $EAP_HOME/standalone/deployments/activemq-rar.rar

# Move the startup script to EAP_HOME
mv startup.sh $EAP_HOME

