#!/bin/sh

# Exit if an error is encountered
set -e -x

# Unzip EAP to the version-generic home directory
# TODO make more generic so this doesn't have to change for upgrades
echo "unzipping files..."
unzip -q ${INSTALL_DIR}/jboss-eap-7.2.0.zip -d ${EAP_PARENT}
mv ${EAP_PARENT}/jboss-eap-7.2 ${EAP_PARENT}/jboss-eap
chmod +x ${EAP_HOME}/bin/*.sh

# Create ActiveMQ module
#mv ${INSTALL_DIR}/activemq-rar*.rar ${EAP_HOME}/standalone/deployments/activemq-rar.rar

# Put adjusted configuration files into the appropriate directory.  Some will be adjusted at startup
#cp -rf domain/host*.xml ${EAP_HOME}/domain/configuration/
#rm -rf host*.xml

echo "export JBOSS_USER_APP_MODULES_HOME=\"\$EAP_PARENT/modules/app-modules\"" >> ${EAP_HOME}/bin/standalone.conf
echo "export JBOSS_USER_SEC_MODULES_HOME=\"\$EAP_PARENT/modules/sec-modules\"" >> ${EAP_HOME}/bin/standalone.conf
echo "export JBOSS_USER_DATABASES_MODULES_HOME=\"\$EAP_PARENT/modules/db-modules\"" >> ${EAP_HOME}/bin/standalone.conf
echo "export JBOSS_MODULES_HOME=\"\${EAP_HOME}/modules\"" >> ${EAP_HOME}/bin/standalone.conf
echo "export JBOSS_MODULEPATH=\"\$EAP_MODULES:\$JBOSS_MODULES_HOME:\$JBOSS_USER_APP_MODULES_HOME:\$JBOSS_USER_SEC_MODULES_HOME:\$JBOSS_USER_DATABASES_MODULES_HOME\"" >> ${EAP_HOME}/bin/standalone.conf

echo "export JBOSS_USER_APP_MODULES_HOME=\"\$EAP_PARENT/modules/app-modules\"" >> ${EAP_HOME}/bin/domain.conf
echo "export JBOSS_USER_SEC_MODULES_HOME=\"\$EAP_PARENT/modules/sec-modules\"" >> ${EAP_HOME}/bin/domain.conf
echo "export JBOSS_USER_DATABASES_MODULES_HOME=\"\$EAP_PARENT/modules/db-modules\"" >> ${EAP_HOME}/bin/domain.conf
echo "export JBOSS_MODULES_HOME=\"\${EAP_HOME}/modules\"" >> ${EAP_HOME}/bin/domain.conf
echo "export JBOSS_MODULEPATH=\"\$EAP_MODULES:\$JBOSS_MODULES_HOME:\$JBOSS_USER_APP_MODULES_HOME:\$JBOSS_USER_SEC_MODULES_HOME:\$JBOSS_USER_DATABASES_MODULES_HOME\"" >> ${EAP_HOME}/bin/domain.conf

# Necessary so that the flattening doesn't keep these
rm -rf ${INSTALL_DIR}

# Move the startup scripts to EAP_HOME
mv entrypoint.sh ${EAP_HOME}/
