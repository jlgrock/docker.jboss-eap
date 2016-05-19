FROM jlgrock/centos-oraclejdk:6.6-8u45
MAINTAINER Justin Grant <jlgrock@gmail.com>

ENV EAP_PARENT /opt/app/jboss
ENV EAP_HOME $EAP_PARENT/jboss-eap
ENV JBOSS_HOME $EAP_PARENT/jboss-eap

RUN mkdir -p $EAP_PARENT/modules/app-modules
RUN mkdir -p $EAP_PARENT/modules/sec-modules
RUN mkdir -p $EAP_PARENT/modules/db-modules

ADD resources/ $EAP_PARENT/
ADD install_files/ $EAP_PARENT/
ADD VERSION $EAP_PARENT/VERSION
ADD loadenv.sh $EAP_PARENT/loadenv.sh

WORKDIR $EAP_PARENT
RUN chmod +x *.sh
RUN ./install_eap.sh

### Open Ports
# Web, Management Console, Management Console API, Web Proxy, MOD_CLUSTER Manager
EXPOSE 8080 9990 9999 80 10001

### Start EAP
CMD $EAP_HOME/startup.sh
