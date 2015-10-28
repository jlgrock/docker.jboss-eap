#!/bin/sh

###############################################################
# This script will build the core version of the EAP instance,
# storing the image to jlgrock/jboss-eap.  If you drop extra WARs
# into the install directory, you can create a custom deployment.
# It is suggested that you don't use this script though, as you'll
# want to store this image to something other than jlgrock/jboss-eap.
# For example, you can put webapp.war in there and create an instance
# called my/webapp.
###############################################################

# load the versions
. ./loadenv.sh

echo "Processing for JBOSS EAP Version $JBOSS_EAP"

if [ ! -e install_files/jboss-eap-$JBOSS_EAP.zip ]
then
	echo "could not find file install_files/jboss-eap-$JBOSS_EAP.zip"
	echo "You should put the required JBoss EAP binary into the root directory first."
	exit 255
fi

# Create containers
echo "Creating JBoss EAP Container ..."
docker build -q --rm -t jlgrock/jboss-eap:$JBOSS_EAP .

if [ $? -eq 0 ]; then
    echo "Container Built"
else
    echo "Error: Unable to Build Container"
fi
