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

FROM_IMAGE_NAME=jlgrock/centos-oraclejdk
FROM_IMAGE_VERSION=6.6-8u45
IMAGE_NAME=jlgrock/jboss-eap
IMAGE_VERSION=$JBOSS_EAP
TMP_IMAGE_NAME="${IMAGE_NAME}-temp"

echo "Processing for JBOSS EAP Version $JBOSS_EAP"

if [ ! -e install_files/jboss-eap-$JBOSS_EAP.zip ]; then
	echo "could not find file install_files/jboss-eap-$JBOSS_EAP.zip"
	echo "You should put the required JBoss EAP binary into the root directory first."
	exit 255
fi

if [ ! -e install_files/activemq-rar*.rar ]; then
	echo "could not find file install_files/jboss-activemq-rar*.rar"
	echo "You should put the required JBoss A-MQ connector in the root directory first."
	exit 255
fi

# pull latest from repo
docker pull ${FROM_IMAGE_NAME}:${FROM_IMAGE_VERSION}

# Create a temporary image
echo "Creating JBoss EAP Image ..."
docker build -q --rm -t ${TMP_IMAGE_NAME}:${IMAGE_VERSION} .

# Start Image and get ID
ID=$(docker run -d ${TMP_IMAGE_NAME}:${IMAGE_VERSION} /bin/bash)
echo "Container ID '$ID' now running"

# Flatten the image (removes AUFS layers) and create a new image
FLAT_ID=$(docker export ${ID} | docker import - ${IMAGE_NAME}:${IMAGE_VERSION})
echo "Created Flattened image with ID: ${FLAT_ID} for ${IMAGE_NAME}:${IMAGE_VERSION}"

# Cleanup
echo "destroying intermediate containers related to $TMP_IMAGE_NAME (all versions)"
docker ps -a | awk '{ print $1,$2 }' | grep ${TMP_IMAGE_NAME} | awk '{ print $1 }' | xargs -I {} docker rm {}
docker images -a | awk '{ print $1, $3 }' | grep ${TMP_IMAGE_NAME} | awk '{ print $2 }' | xargs -I {} docker rmi {}

if [ $? -eq 0 ]; then
    echo "Container Built"
else
    echo "Error: Unable to Build Container"
fi
