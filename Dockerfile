FROM jlgrock/centos-oraclejdk:6.6-8u45
MAINTAINER Justin Grant <jlgrock@gmail.com>

ENV EAP_PARENT /opt/jboss
ENV EAP_HOME $EAP_PARENT/jboss-eap

ADD install_files/ $EAP_PARENT/
ADD VERSION $EAP_PARENT/VERSION
ADD loadenv.sh $EAP_PARENT/loadenv.sh

WORKDIR $EAP_PARENT
RUN ./install_eap.sh

### Create EAP User
RUN $EAP_HOME/bin/add-user.sh admin admin123! --silent

### Configure EAP
RUN echo "JAVA_OPTS=\"\$JAVA_OPTS -Djboss.bind.address=0.0.0.0 -Djboss.bind.address.management=0.0.0.0\"" >> $EAP_HOME/bin/standalone.conf

### Open Ports
# Web, Management Console, Management Console API
EXPOSE 8080 9990 9999

### Start EAP
CMD $EAP_HOME/startup.sh
