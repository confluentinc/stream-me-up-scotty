resource "confluent_kafka_cluster" "default_cluster" {
    display_name = "default_cluster"
    availability = "SINGLE_ZONE"
    cloud = "AWS"
    region = "us-east-2"
    basic {}
    environment {
        id = confluent_environment.default_env.id
    }
    lifecycle {
        prevent_destroy = false
    }
}