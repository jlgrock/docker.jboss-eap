#!/bin/sh

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
