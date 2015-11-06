FROM jlgrock/centos-oraclejdk:6.6-8u45
MAINTAINER Justin Grant <jlgrock@gmail.com>

ENV EAP_PARENT /opt/jboss
ENV EAP_HOME $EAP_PARENT/jboss-eap
ENV JBOSS_HOME $EAP_PARENT/jboss-eap

ADD resources/ $EAP_PARENT/
ADD install_files/ $EAP_PARENT/
ADD VERSION $EAP_PARENT/VERSION
ADD loadenv.sh $EAP_PARENT/loadenv.sh

WORKDIR $EAP_PARENT
RUN ./install_eap.sh

### Create EAP User
RUN $EAP_HOME/bin/add-user.sh admin admin123! --silent

### Open Ports
# Web, Management Console, Management Console API
EXPOSE 8080 9990 9999

### Start EAP
CMD $EAP_HOME/startup.sh
