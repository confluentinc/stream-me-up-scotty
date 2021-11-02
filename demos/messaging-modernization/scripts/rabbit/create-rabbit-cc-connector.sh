curl -i -X PUT -H  "Content-Type:application/json" \
    http://localhost:8083/connectors/source-rabbitmq-00/config \
    -d '{
        "connector.class" : "io.confluent.connect.rabbitmq.RabbitMQSourceConnector",
        "kafka.topic" : "from-rabbit",
        "rabbitmq.queue" : "test-queue-01",
        "rabbitmq.username": "guest",
        "rabbitmq.password": "guest",
        "rabbitmq.host": "rabbitmq",
        "rabbitmq.port": "5672",
        "rabbitmq.virtual.host": "/",
        "key.converter": "org.apache.kafka.connect.storage.StringConverter",
        "value.converter": "org.apache.kafka.connect.converters.ByteArrayConverter",
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
    } '
