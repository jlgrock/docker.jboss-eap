FROM jlgrock/centos-oraclejdk:6.6-8u144
MAINTAINER Justin Grant <jlgrock@gmail.com>

ENV EAP_PARENT /opt/app/jboss
ENV EAP_HOME $EAP_PARENT/jboss-eap
ENV ENCRYPT_PASSWORD encryptPassword

RUN mkdir -p $EAP_PARENT/modules/app-modules \
	$EAP_PARENT/modules/sec-modules \
	$EAP_PARENT/modules/db-modules \
	$EAP_PARENT/modules/app-modules/org/apache/activemq/ra/main/

# Set the working directory for installation
WORKDIR $EAP_PARENT

ADD resources/ $EAP_PARENT/
ADD install-files/ $EAP_PARENT/install-files/

# Run the script that installs everything
RUN ./install_eap.sh

