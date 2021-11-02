curl -i -X PUT \
     -H "Content-Type: application/json" \
     --data '{
             "connector.class": "io.confluent.connect.activemq.ActiveMQSourceConnector",
             "kafka.topic": "from-activemq",
             "activemq.url": "tcp://activemq:61616",
             "jms.destination.name": "DEV.QUEUE.1",
             "jms.destination.type": "queue",
             "key.converter": "io.confluent.connect.avro.AvroConverter",
             "value.converter": "io.confluent.connect.avro.AvroConverter",
             "key.converter.schema.registry.url":"http://schema-registry:8081",
             "value.converter.schema.registry.url":"http://schema-registry:8081",
             "confluent.license": "",
             "confluent.topic.bootstrap.servers": "broker:29092",
             "confluent.topic.replication.factor": "1"
          }' \
     http://localhost:8083/connectors/active-mq-source/config 
