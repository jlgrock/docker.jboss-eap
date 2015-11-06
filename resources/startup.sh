if [[ ! "$MODE" ]]; then
	MODE="STANDALONE"
fi

if [[ ! "$MESSAGE_QUEUE" ]]; then
	MESSAGE_QUEUE="HORNETQ"
fi

case "$MESSAGE_QUEUE" in
	HORNETQ*)
		# Do nothing
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


case "$MODE" in
	STANDALONE*)
		echo "Starting EAP Server as Standalone"
		if [[ "$MQ_USER_LOGIN" ]]; then
			OPTS="$OPTS -Dactivemq.username=$MQ_USER_LOGIN"
		fi
		if [[ "$MQ_USER_LOGIN" ]]; then
			OPTS="$OPTS -Dactivemq.username=$MQ_USER_LOGIN"
		fi
		if [[ "$MQ_USER_PASSWORD" ]]; then
			OPTS="$OPTS -Dactivemq.password=$MQ_USER_PASSWORD"
		fi
		if [[ "$MQ_HOST" ]]; then
			OPTS="$OPTS -Dactivemq.host=$MQ_HOST"
		fi
		if [[ "$MQ_PORT" ]]; then
			OPTS="$OPTS -Dactivemq.port=$MQ_PORT"
		fi
		echo "OPTS=$OPTS"
			
		$EAP_HOME/bin/standalone.sh -c standalone.xml $OPTS -Djboss.bind.address=$HOSTNAME \
                       -Djboss.bind.address.unsecure=$HOSTNAME \
                       -Djboss.bind.address.management=$HOSTNAME

	;;
	DOMAIN_MASTER*)
		echo "Starting EAP Server as Domain Master"
		if [[ $HOSTNAME ]]; then
			OPTS="$OPTS -Djboss.bind.address.management=$HOSTNAME"
		fi
		echo "OPTS=$OPTS"
		$EAP_HOME/bin/domain.sh --host-config=host-master.xml $OPTS
	;;
	DOMAIN_SLAVE*)
		echo "Starting EAP Server as Domain Slave"
		echo "Connecting to Master at $MASTER_PORT_9999_TCP_ADDR:$MASTER_PORT_9999_TCP_PORT"
		echo "OPTS=$OPTS"
		$EAP_HOME/bin/domain.sh --host-config=host-slave.xml \
			-Djboss.domain.master.address=$MASTER_PORT_9999_TCP_ADDR \
			-Djboss.domain.master.port=$MASTER_PORT_9999_TCP_PORT \
			-Djboss.bind.address=$HOSTNAME \
			-Djboss.bind.address.unsecure=$HOSTNAME \
			-Djboss.bind.address.management=$HOSTNAME \
			-Dactivemq.username=$MQ_USER_LOGIN \
			-Dactivemq.password=MQ_USER_PASSWORD \
			-Dactivemq.host=$MQ_HOST \
			-Dactivemq.port=$MQ_PORT
	
	;;
	*)
		echo "Invalid option for MODE=$MODE"
		exit 1
	;;
esac