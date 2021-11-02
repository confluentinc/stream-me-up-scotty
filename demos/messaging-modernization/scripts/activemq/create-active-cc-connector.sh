curl -i -X PUT \
     -H "Content-Type: application/json" \
     --data '{
             "connector.class": "io.confluent.connect.activemq.ActiveMQSourceConnector",
             "kafka.topic": "from-activemq",
             "activemq.url": "tcp://activemq:61616",
             "jms.destination.name": "DEV.QUEUE.1",
             "jms.destination.type": "queue",
             "tasks.max": 1,
             "errors.log.enable": true,
             "key.converter": "io.confluent.connect.avro.AvroConverter",
             "value.converter": "io.confluent.connect.avro.AvroConverter",
             "key.converter.schema.registry.url": "'"${SCHEMA_REGISTRY_URL}"'",
             "key.converter.basic.auth.credentials.source":"USER_INFO",
             "key.converter.schema.registry.basic.auth.user.info": "'"${SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO}"'",
             "value.converter.schema.registry.url": "'"${SCHEMA_REGISTRY_URL}"'",
             "value.converter.basic.auth.credentials.source":"USER_INFO",
             "value.converter.schema.registry.basic.auth.user.info": "'"${SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO}"'",
             "confluent.license": "",
             "confluent.topic.bootstrap.servers": "'"${BOOTSTRAP_SERVERS}"'",
             "confluent.topic.sasl.jaas.config": "org.apache.kafka.common.security.plain.PlainLoginModule required username=\"'"$CLOUD_KEY"'\" password=\"'"$CLOUD_SECRET"'\";",
             "confluent.topic.security.protocol":"SASL_SSL",
             "confluent.topic.sasl.mechanism":"PLAIN",
             "confluent.topic.replication.factor": "1"
          }' http://localhost:8083/connectors/active-mq-source/config 
