#!/bin/bash

# Exit if an error is encountered
set -e

# Copies the full config over for use
reset_config() {
    /bin/cp -f ${EAP_HOME}/standalone/configuration/standalone-full.xml ${EAP_HOME}/standalone/configuration/standalone.xml
}

# check to see if the keystore and truststore files exist.  If they don't, throw an exception and stop the image.
check_store_files() {
    if ! ls /amq/store/client/client.ks \
        /amq/store/client/client.ts \
        &> /dev/null; then
          
        # heredoc formatted error
        cat <<- ERROR
Missing required store files:
- /amq/store/client/client.ks
- /amq/store/client/client.ts
ERROR
        exit 1
    fi
}

### Set defaults for any of the environment variables
set_defaults() {
    if [[ ! "${MODE}" ]]; then
        MODE="STANDALONE"
    fi

    if [[ ! "${EAP_USERNAME}" ]]; then
        EAP_USERNAME="admin"
    fi

    if [[ ! "${EAP_PASSWORD}" ]]; then
        EAP_PASSWORD="admin123!"
    fi

    if [[ ! "${MESSAGE_QUEUE}" ]]; then
        MESSAGE_QUEUE="NONE"
    fi

    if [[ ! "${AMQ_SSL}" ]]; then
        AMQ_SSL="false"
    fi
}

# Check to make sure that the environment variables are the allowable values, error if they are not.
check_env_values() {
    if [[ "${MODE,,}" != 'standalone' ]] && [[ "${MODE,,}" != 'domain_master' ]] && [[ "${MODE,,}" != 'domain_slave' ]]; then
        echo "ERROR: MODE environment variable must be the values 'STANDALONE', 'DOMAIN_MASTER' or 'DOMAIN_SLAVE'"
        echo "The value provided was '${MODE}'"
        exit 1
    fi

    if [[ "${AMQ_SSL,,}" != 'true' ]] && [[ "${AMQ_SSL,,}" != 'false' ]]; then
        echo "ERROR: AMQ_SSL environment variable must be the values 'TRUE' or 'FALSE'"
        echo "The value provided was '${AMQ_SSL}'"
        exit 1
    fi

    if [[ "${MESSAGE_QUEUE,,}" != 'none' ]] && [[ "${MESSAGE_QUEUE,,}" != 'artemis' ]]; then
        echo "ERROR: MESSAGE_QUEUE should be either 'NONE' or 'ARTEMIS'"
        echo "The value provided was '${MESSAGE_QUEUE}'"
        exit 1
    fi
}

### Create EAP User
create_eap_user() {
    ${EAP_HOME}/bin/add-user.sh ${EAP_USERNAME} ${EAP_PASSWORD} --silent
}

# Creates the options to be passed to the program that will start up jboss, facilitating variable replacement in the
# XML files
create_option_string() {
    OPTS="$OPTS"
    if [[ "${MIN_SERVER_GROUP_HEAP}" ]]; then
        OPTS = "${OPTS} -Djvm.group.heap.min=${MIN_SERVER_GROUP_HEAP}"
    fi
    if [[ "${MAX_SERVER_GROUP_HEAP}" ]]; then
        OPTS = "${OPTS} -Djvm.group.heap.max=${MAX_SERVER_GROUP_HEAP}"
    fi
    if [[ "${MIN_INSTANCE_HEAP}" ]]; then
        OPTS = "${OPTS} -Djvm.instance.heap.min=${MIN_INSTANCE_HEAP}"
        sed -i -e "s/-Xms1303m/-Xms${MIN_INSTANCE_HEAP}/g" $EAP_HOME/bin/standalone.conf
    fi
    if [[ "${MAX_INSTANCE_HEAP}" ]]; then
        OPTS = "${OPTS} -Djvm.instance.heap.max=${MAX_INSTANCE_HEAP}"
        sed -i -e "s/-Xmx1303m/-Xmx$MAX_INSTANCE_HEAP/g" $EAP_HOME/bin/standalone.conf
    fi
    if [[ "${MQ_HOST}" ]]; then
        OPTS="${OPTS} -Dartemis.host=${MQ_HOST}"
    fi

    if [[ "${MQ_PORT}" ]]; then
        OPTS="${OPTS} -Dartemis.port=${MQ_PORT}"
    fi

    if [[ "${MQ_USER_LOGIN}" ]]; then
        OPTS = "${OPTS} -Dartemis.user=${MQ_USER_PASSWORD}"
    fi

    if [[ "${MQ_USER_PASSWORD}" ]]; then
        OPTS = "${OPTS} -Dartemis.password=${MQ_USER_PASSWORD}"
    fi

    # set the host ip for eth0 - this may not scale well
    HOST_IP=$(/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')

    OPTS="${OPTS} -Djboss.bind.address=${HOST_IP}"
    OPTS="${OPTS} -Djboss.bind.address.unsecure=${HOST_IP}"
    OPTS="${OPTS} -Djboss.bind.address.management=${HOST_IP}"

    echo "Created Option String: ${OPTS}"
}


remove_amq() {
    echo "Removing AMQ sections"

    xmlstarlet ed \
    --inplace \
    -d "/*[local-name() = 'server']/*[local-name() = 'profile']/*[local-name() = 'subsystem'][namespace-uri() = 'urn:jboss:domain:messaging-activemq:4.0']" \
    -d "/*[local-name() = 'server']/*[local-name() = 'extensions']/*[local-name() = 'extension'][@module = 'org.wildfly.extension.messaging-activemq']" \
    ${EAP_HOME}/standalone/configuration/standalone.xml
}

update_amq() {
    echo "Updating AMQ sections"

    xmlstarlet tr "${EAP_PARENT}/messaging-subsystem-amq.xslt" "${EAP_HOME}/standalone/configuration/standalone.xml" > "${EAP_HOME}/standalone/configuration/standalone2.xml"
    xmlstarlet tr "${EAP_PARENT}/output-binding-amq.xslt" "${EAP_HOME}/standalone/configuration/standalone2.xml" > "${EAP_HOME}/standalone/configuration/standalone3.xml"
    mv "${EAP_HOME}/standalone/configuration/standalone3.xml" "${EAP_HOME}/standalone/configuration/standalone.xml"
    rm -rf "${EAP_HOME}/standalone/configuration/standalone2.xml"
}

start_standalone() {
    if [[ "${MESSAGE_QUEUE,,}" == "artemis" ]]; then
        update_amq
    else
        remove_amq
    fi

    create_option_string

    ${EAP_HOME}/bin/standalone.sh -c standalone.xml ${OPTS}
}

start_domain_master() {
    if [[ "${MESSAGE_QUEUE,,}" == "artemis" ]]; then
        update_amq
    else
        remove_amq
    fi

    create_option_string

    ${EAP_HOME}/bin/domain.sh --host-config=host-master.xml ${OPTS}
}

start_domain_slave() {
    if [[ "${MESSAGE_QUEUE,,}" == "artemis" ]]; then
        update_amq
    else
        remove_amq
    fi

    create_option_string

    ${EAP_HOME}/bin/domain.sh --host-config=host-slave.xml ${OPTS}
}

reset_config
set_defaults
check_env_values
create_eap_user

case "${MODE}" in
    STANDALONE*)
        echo "Starting EAP Server in STANDALONE mode"
        start_standalone
    ;;
    DOMAIN_MASTER*)
        echo "Starting EAP Server in DOMAIN mode as Domain Master"
        start_domain_master
    ;;
    DOMAIN_SLAVE*)
        echo "Starting EAP Server in DOMAIN mode as Domain Slave"
        start_domain_master
esac

# TODO Currently doesn't have an ssl for ha mode.
#cp -rf ${EAP_PARENT}/standalone-full-ha-amq.xml ${EAP_HOME}/standalone/configuration/standalone-full-ha.xml
#cp -rf ${EAP_PARENT}/domain-amq.xml ${EAP_HOME}/domain/configuration/domain.xml


