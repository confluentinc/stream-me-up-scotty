resource "confluent_kafka_topic" "default_topic" {
    kafka_cluster {
        id = confluent_kafka_cluster.default_cluster.id
    }
    topic_name = "default_topic"
    partitions_count = 1
    rest_endpoint = confluent_kafka_cluster.default_cluster.rest_endpoint
    credentials {
        key = confluent_api_key.app_manager_default_cluster_key.id
        secret = confluent_api_key.app_manager_default_cluster_key.secret
    }
    lifecycle {
        prevent_destroy = false
    }
}