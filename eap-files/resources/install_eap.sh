#!/bin/sh

# Exit if an error is encountered
set -e

# Unzip EAP to the version-generic home directory
# TODO make more generic so this doesn't have to change for upgrades
echo "unzipping files..."
unzip -q $INSTALL_DIR/jboss-eap-6.4.0.zip
mv jboss-eap-* $EAP_HOME/

# install the patch
$EAP_HOME/bin/jboss-cli.sh --command="patch apply $INSTALL_DIR/jboss-eap-6.4.6-patch.zip"

# Create ActiveMQ module
mv $INSTALL_DIR/activemq-rar*.rar $EAP_HOME/standalone/deployments/activemq-rar.rar

# Put adjusted configuration files into the appropriate directory.  Some will be adjusted at startup
cp -rf host*.xml $EAP_HOME/domain/configuration/
rm -rf host*.xml

echo "export JBOSS_USER_APP_MODULES_HOME=\"\$EAP_PARENT/modules/app-modules\"" >> $EAP_HOME/bin/standalone.conf
echo "export JBOSS_USER_SEC_MODULES_HOME=\"\$EAP_PARENT/modules/sec-modules\"" >> $EAP_HOME/bin/standalone.conf
echo "export JBOSS_USER_DATABASES_MODULES_HOME=\"\$EAP_PARENT/modules/db-modules\"" >> $EAP_HOME/bin/standalone.conf
echo "export JBOSS_MODULES_HOME=\"\$EAP_HOME/modules\"" >> $EAP_HOME/bin/standalone.conf
echo "export JBOSS_MODULEPATH=\"\$EAP_MODULES:\$JBOSS_MODULES_HOME:\$JBOSS_USER_APP_MODULES_HOME:\$JBOSS_USER_SEC_MODULES_HOME:\$JBOSS_USER_DATABASES_MODULES_HOME\"" >> $EAP_HOME/bin/standalone.conf

echo "export JBOSS_USER_APP_MODULES_HOME=\"\$EAP_PARENT/modules/app-modules\"" >> $EAP_HOME/bin/domain.conf
echo "export JBOSS_USER_SEC_MODULES_HOME=\"\$EAP_PARENT/modules/sec-modules\"" >> $EAP_HOME/bin/domain.conf
echo "export JBOSS_USER_DATABASES_MODULES_HOME=\"\$EAP_PARENT/modules/db-modules\"" >> $EAP_HOME/bin/domain.conf
echo "export JBOSS_MODULES_HOME=\"\$EAP_HOME/modules\"" >> $EAP_HOME/bin/domain.conf
echo "export JBOSS_MODULEPATH=\"\$EAP_MODULES:\$JBOSS_MODULES_HOME:\$JBOSS_USER_APP_MODULES_HOME:\$JBOSS_USER_SEC_MODULES_HOME:\$JBOSS_USER_DATABASES_MODULES_HOME\"" >> $EAP_HOME/bin/domain.conf

# Necessary so that the flattening doesn't keep these
rm -rf $INSTALL_DIR

# Move the startup scripts to EAP_HOME
mv entrypoint.sh $EAP_HOME/
