CREATE SINK CONNECTOR SINK_ELASTIC_TEST_07 WITH (
  'connector.class' = 'io.confluent.connect.elasticsearch.ElasticsearchSinkConnector',
  'connection.url'  = 'http://elasticsearch:9200',
  'key.converter'   = 'org.apache.kafka.connect.storage.StringConverter',
  'type.name'       = 'doc',
  'topics'          = 'transactions',
  'key.ignore'      = 'true',
  'schema.ignore'   = 'false'
);

