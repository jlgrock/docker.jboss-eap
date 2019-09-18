FROM jlgrock/centos-openjdk:6.6-8u221
MAINTAINER Justin Grant <jlgrock@gmail.com>

ENV EAP_PARENT /opt/app/jboss
ENV EAP_HOME ${EAP_PARENT}/jboss-eap
ENV DEPLOYMENT_HOME ${EAP_PARENT}/deployments
ENV INSTALL_DIR ${EAP_PARENT}/install-files

RUN mkdir -p ${EAP_PARENT}/modules/app-modules \
	${EAP_PARENT}/modules/sec-modules \
	${EAP_PARENT}/modules/db-modules \
	${INSTALL_DIR}

# Set the working directory for installation
WORKDIR ${EAP_PARENT}

ADD resources/ ${EAP_PARENT}/
ADD install-files/ ${INSTALL_DIR}

RUN touch /var/lib/rpm/* && \
    yum install -y epel-release && \
    yum install -y xmlstarlet \
        unzip

# Run the script that installs everything
RUN ./install_eap.sh

