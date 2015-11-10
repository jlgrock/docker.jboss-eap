#!/bin/sh

# Load the current versions
. ./loadenv.sh

# set the host ip for eth0 - this may not scale well
HOST_IP=$(/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')

if [[ ! "$MODE" ]]; then
	MODE="STANDALONE"
fi

if [[ ! "$MESSAGE_QUEUE" ]]; then
	MESSAGE_QUEUE="HORNETQ"
fi

case "$MESSAGE_QUEUE" in
	HORNETQ*)
		cp -rf ./domain.xml $EAP_HOME/domain/configuration/domain.xml
	;;
	ACTIVE_MQ*)
		cp -rf ./standalone-amq.xml $EAP_HOME/standalone/configuration/standalone.xml		
		cp -rf ./standalone-full-ha-amq.xml $EAP_HOME/standalone/configuration/standalone-full-ha.xml
		cp -rf ./domain-amq.xml $EAP_HOME/domain/configuration/domain.xml
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
fi
if [[ "$MAX_INSTANCE_HEAP" ]]; then
	OPTS = "$OPTS --Djvm.instance.heap.max=$MAX_INSTANCE_HEAP"
fi
if [[ "$MQ_HOST" ]]; then
	OPTS="$OPTS -Dactivemq.host=$MQ_HOST"
fi
if [[ "$MQ_PORT" ]]; then
	OPTS="$OPTS -Dactivemq.port=$MQ_PORT"
fi
if [[ "$MQ_USER_LOGIN" ]]; then
	OPTS="$OPTS -Dactivemq.username=$MQ_USER_LOGIN"
fi
if [[ "$MQ_USER_PASSWORD" ]]; then
	OPTS="$OPTS -Dactivemq.password=$MQ_USER_PASSWORD"
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