curl -X PUT \
     -H "Content-Type: application/json" \
     --data '{
               "connector.class": "io.confluent.connect.tibco.TibcoSourceConnector",
               "tasks.max": "1",
               "kafka.topic": "from-tibco",
               "tibco.url": "tcp://tibco-ems:7222",
               "tibco.username": "admin",
               "tibco.password": "",
               "jms.destination.type": "queue",
               "jms.destination.name": "connector-quickstart",
               "key.converter": "io.confluent.connect.avro.AvroConverter",
               "value.converter": "io.confluent.connect.avro.AvroConverter",
               "key.converter.schema.registry.url":"http://schema-registry:8081",
               "value.converter.schema.registry.url":"http://schema-registry:8081",
               "confluent.topic.bootstrap.servers": "broker:29092",
               "confluent.topic.replication.factor": "1"
      }' \
     http://localhost:8083/connectors/tibco-ems-source/config
