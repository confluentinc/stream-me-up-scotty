curl -X PUT \
     -H "Content-Type: application/json" \
     --data '{
              "connector.class": "io.confluent.connect.elasticsearch.ElasticsearchSinkConnector",
              "tasks.max": "1",
              "topics": "transactions",
              "topic.index.map": "transactions:transactions",
              "connection.url": "http://elasticsearch:9200",
              "type.name": "doc",
              "key.ignore": true,
              "key.converter": 'org.apache.kafka.connect.storage.StringConverter',
              "schema.ignore": false
      }' \
     http://localhost:8083/connectors/elasticsearch-sink/config
