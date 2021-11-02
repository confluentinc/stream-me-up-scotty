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
        "confluent.license":"",
        "confluent.topic.bootstrap.servers":"broker:29092",
        "confluent.topic.replication.factor":1,
        "value.converter": "org.apache.kafka.connect.converters.ByteArrayConverter",
        "key.converter": "org.apache.kafka.connect.storage.StringConverter"
    } '
