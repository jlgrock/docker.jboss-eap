FROM jlgrock/jboss-eap-files:6.4.6
MAINTAINER Justin Grant <jlgrock@gmail.com>

# Set the environment variables.  The encryption password can be overwritten
ENV EAP_PARENT /opt/app/jboss
ENV EAP_HOME $EAP_PARENT/jboss-eap
ENV ENCRYPT_PASSWORD encryptPassword

# Set the working directory for execution
WORKDIR $EAP_HOME

# TODO make a nice volume mapping.  This could work, but then what would you do if you want to extend
# and not to map
# Allow user to mount deployment directory if that is desired
#VOLUME $EAP_HOME/standalone/deployments

### Open Ports
# Web, Management Console, Management Console API, Web Proxy, MOD_CLUSTER Manager
EXPOSE 8080 9990 9999 80 10001

# Determines what settings are applied, what security is applied, then starts up the service.
ENTRYPOINT ["./entrypoint.sh"]
