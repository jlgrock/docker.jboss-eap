FROM jlgrock/centos-oraclejdk:6.6-8u161
MAINTAINER Justin Grant <jlgrock@gmail.com>

ENV EAP_PARENT /opt/app/jboss
ENV EAP_HOME $EAP_PARENT/jboss-eap
ENV ENCRYPT_PASSWORD encryptPassword
ENV INSTALL_DIR $EAP_PARENT/install-files

RUN mkdir -p $EAP_PARENT/modules/app-modules \
	$EAP_PARENT/modules/sec-modules \
	$EAP_PARENT/modules/db-modules \
	$EAP_PARENT/modules/app-modules/org/apache/activemq/ra/main/ \
	$INSTALL_DIR

# Set the working directory for installation
WORKDIR $EAP_PARENT

ADD resources/ $EAP_PARENT/
ADD install-files/ $INSTALL_DIR

# Run the script that installs everything
RUN ./install_eap.sh

