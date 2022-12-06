resource "local_file" "client_props" {
    filename = "../client.properties"
    content = <<-EOT
    bootstrap.servers=${substr(confluent_kafka_cluster.default_cluster.bootstrap_endpoint,11,-1)}
    security.protocol=SASL_SSL
    sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule   required username='${confluent_api_key.clients_default_cluster_key.id}'   password='${confluent_api_key.clients_default_cluster_key.secret}';
    sasl.mechanism=PLAIN
    client.dns.lookup=use_all_dns_ips
    EOT
}