#!/bin/bash

# Exit if an error is encountered
set -e

check_store_files() {
    if ! ls /amq/store/client/client.ks \
        /amq/store/client/client.ts \
        /amq/store/pw/keystore_pw \
        /amq/store/irs-jasypt/bin/decrypt.sh \
        &> /dev/null; then
          
        # heredoc formatted error
        cat <<- ERROR
Missing required store files:
- /amq/store/client/client.ks
- /amq/store/client/client.ts
- /amq/store/pw/keystore_pw
- /amq/store/irs-jasypt/bin/decrypt.sh
ERROR
        exit 1
    fi
}

export_amq_vars() {
    export MESSAGE_QUEUE=ACTIVE_MQ
    
    if [[ "$AMQ_PORT_61616_TCP_ADDR" ]]; then
        export MQ_HOST="$AMQ_PORT_61616_TCP_ADDR"
    fi
    
    if [[ "$AMQ_PORT_61616_TCP_PORT" ]]; then
        export MQ_PORT="$AMQ_PORT_61616_TCP_PORT"
    fi
}

args="$@"
OPTS="$OPTS"
startup_script=""
amq_ssl=false
while [[ -n $1 ]]; do
    case $1 in
        --startup-script)
            shift
        	startup_script="$1"
        ;;
        -D)
            shift
            OPTS="$OPTS -D$1"
        ;;
        --amq-ssl)
            amq_ssl=true
        ;;
        *)
        ;;
    esac
    shift
done

startup_script_path="$EAP_HOME/$startup_script"
if [[ -n "$startup_script" && -e "$startup_script_path" ]]; then
	echo "Executing startup script"
	chmod 770 $startup_script_path
	. $startup_script_path
fi

# set the host ip for eth0 - this may not scale well
HOST_IP=$(/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')


if [[ ! "$MODE" ]]; then
    MODE="STANDALONE"
fi

if [[ ! "$EAP_USERNAME" ]]; then
    EAP_USERNAME="admin"
fi

if [[ ! "$EAP_PASSWORD" ]]; then
    EAP_PASSWORD="admin123!"
fi

if [[ ! "$MESSAGE_QUEUE" ]]; then
    MESSAGE_QUEUE="NONE"
fi

### Create EAP User
$EAP_HOME/bin/add-user.sh $EAP_USERNAME $EAP_PASSWORD --silent

case "$MESSAGE_QUEUE" in
    HORNETQ*)
        cp -rf $EAP_PARENT/domain.xml $EAP_HOME/domain/configuration/domain.xml
    ;;
    ACTIVE_MQ*)
    ACTIVEMQ*)
        if [ "$amq_ssl" = true ]; then
            echo "Configuring EAP with AMQ SSL"
            check_store_files
            export_amq_vars
            export_store_password
            cp -rf $EAP_PARENT/standalone-amq-ssl.xml $EAP_HOME/standalone/configuration/standalone.xml
        else
            echo "Configuring EAP with AMQ without SSL"
            export_amq_vars
            cp -rf $EAP_PARENT/standalone-amq-no-ssl.xml $EAP_HOME/standalone/configuration/standalone.xml
        fi

        # TODO Currently doesn't have an ssl for ha mode.
        cp -rf $EAP_PARENT/standalone-full-ha-amq.xml $EAP_HOME/standalone/configuration/standalone-full-ha.xml
        cp -rf $EAP_PARENT/domain-amq.xml $EAP_HOME/domain/configuration/domain.xml
    ;;
    NONE*)
        cp -rf $EAP_PARENT/standalone-no-amq.xml $EAP_HOME/standalone/configuration/standalone.xml
        cp -rf $EAP_PARENT/standalone-full-ha-no-amq.xml $EAP_HOME/standalone/configuration/standalone-full-ha.xml
        cp -rf $EAP_PARENT/domain-amq.xml $EAP_HOME/domain/configuration/domain.xml
    ;;
    *)
        echo "Invalid option for MESSAGE_QUEUE=$MESSAGE_QUEUE"
        exit 1
    ;;
esac    

if [[ "$MIN_SERVER_GROUP_HEAP" ]]; then
    OPTS = "$OPTS --Djvm.group.heap.min=$MIN_SERVER_GROUP_HEAP"
fi
if [[ "$MAX_SERVER_GROUP_HEAP" ]]; then
    OPTS = "$OPTS --Djvm.group.heap.max=$MAX_SERVER_GROUP_HEAP"
fi
if [[ "$MIN_INSTANCE_HEAP" ]]; then
    OPTS = "$OPTS --Djvm.instance.heap.min=$MIN_INSTANCE_HEAP"
    sed -i -e "s/-Xms1303m/-Xms$MIN_INSTANCE_HEAP/g" $EAP_HOME/bin/standalone.conf
fi
if [[ "$MAX_INSTANCE_HEAP" ]]; then
    OPTS = "$OPTS --Djvm.instance.heap.max=$MAX_INSTANCE_HEAP"
    sed -i -e "s/-Xmx1303m/-Xmx$MAX_INSTANCE_HEAP/g" $EAP_HOME/bin/standalone.conf
fi
if [[ "$MQ_HOST" ]]; then
    OPTS="$OPTS -Dactivemq.host=$MQ_HOST"
fi

if [[ "$MQ_PORT" ]]; then
    OPTS="$OPTS -Dactivemq.port=$MQ_PORT"
fi


OPTS="$OPTS -Djboss.bind.address=$HOST_IP"
OPTS="$OPTS -Djboss.bind.address.unsecure=$HOST_IP"
OPTS="$OPTS -Djboss.bind.address.management=$HOST_IP"

case "$MODE" in
    STANDALONE*)
        echo "Starting EAP Server as Standalone"
        
        echo "OPTS=$OPTS"   
        $EAP_HOME/bin/standalone.sh -c standalone.xml $OPTS
    ;;
    DOMAIN_MASTER*)
        echo "Starting EAP Server as Domain Master with mod_cluster load balancer"

        #set up load balancer
        wget http://downloads.jboss.org/mod_cluster//$MOD_CLUSTER_VERSION/linux-x86_64/mod_cluster-$MOD_CLUSTER_VERSION-linux2-x64-so.tar.gz
        tar xvfz mod_cluster-$MOD_CLUSTER_VERSION-linux2-x64-so.tar.gz -C /etc/httpd/modules/
        cp -rf $EAP_PARENT/httpd.conf /etc/httpd/conf/httpd.conf
        sed -i s/localhost/$HOST_IP/g /etc/httpd/conf/httpd.conf
        service httpd start

        echo "OPTS=$OPTS"
        $EAP_HOME/bin/domain.sh --host-config=host-master.xml $OPTS
    ;;
    DOMAIN_SLAVE*)
        echo "Starting EAP Server as Domain Slave"
        
        echo "Waiting for master admin console to start on $MASTER_PORT_9999_TCP_ADDR:$MASTER_PORT_9990_TCP_PORT"
        while [ "$(curl -s -o /dev/null -I -w "%{http_code}" $MASTER_PORT_9990_TCP_ADDR:$MASTER_PORT_9990_TCP_PORT)" = "000" ]; do
                sleep 1;
        done;
        echo "Master admin console started"
        
        echo "Connecting to Master at $MASTER_PORT_9999_TCP_ADDR:$MASTER_PORT_9999_TCP_PORT"
        
        OPTS="$OPTS -Djboss.domain.master.address=$MASTER_PORT_9999_TCP_ADDR"
        OPTS="$OPTS -Djboss.domain.master.port=$MASTER_PORT_9999_TCP_PORT"

        echo "OPTS=$OPTS"
        $EAP_HOME/bin/domain.sh --host-config=host-slave.xml $OPTS
    ;;
    *)
        echo "Invalid option for MODE=$MODE"
        exit 1
    ;;
esac
