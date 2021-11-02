curl -X PUT \
     -H "Content-Type: application/json" \
     --data '{
             "connector.class": "io.confluent.connect.ibm.mq.IbmMQSourceConnector",
             "kafka.topic": "from-ibmmq",
             "mq.hostname": "ibmmq",
             "mq.port": "1414",
             "mq.transport.type": "client",
             "mq.queue.manager": "QM1",
             "mq.channel": "DEV.APP.SVRCONN",
             "mq.username": "app",
             "mq.password": "passw0rd",
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
     http://localhost:8083/connectors/ibm-mq-source/config
