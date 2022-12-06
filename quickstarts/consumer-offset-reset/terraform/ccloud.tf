terraform {
    required_providers {
        confluent = {
            source = "confluentinc/confluent"
            version = "1.13.0"
        }
        local = {
            source = "hashicorp/local"
            version = "2.2.3"
        }
    }
}

provider "confluent" {
    # Set through env vars as:
    # CONFLUENT_CLOUD_API_KEY="CLOUD-KEY"
    # CONFLUENT_CLOUD_API_SECRET="CLOUD-SECRET"
}
provider "local" {
    # For writing configs to a file
}

resource "random_id" "id" {
    byte_length = 8
}

resource "confluent_environment" "default_env" {
    display_name = "${local.env_name}-${random_id.id.hex}"
    lifecycle {
        prevent_destroy = false
    }
}

resource "confluent_kafka_cluster" "default_cluster" {
    display_name = "${local.cluster_name}"
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

resource "confluent_service_account" "app_manager" {
    display_name = "app-manager-${random_id.id.hex}"
    description = "${local.description}"
}

resource "confluent_service_account" "clients" {
    display_name = "client-${random_id.id.hex}"
    description = "${local.description}"
}

resource "confluent_role_binding" "app_manager_environment_admin" {
    principal = "User:${confluent_service_account.app_manager.id}"
    role_name = "EnvironmentAdmin"
    crn_pattern = confluent_environment.default_env.resource_name
}

resource "confluent_role_binding" "clients_cluster_admin" {
    principal = "User:${confluent_service_account.clients.id}"
    role_name = "CloudClusterAdmin"
    crn_pattern = confluent_kafka_cluster.default_cluster.rbac_crn
}

resource "confluent_kafka_topic" "default_topic" {
    kafka_cluster {
        id = confluent_kafka_cluster.default_cluster.id
    }
    topic_name = "${local.topic_name}"
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

resource "confluent_api_key" "app_manager_default_cluster_key" {
    display_name = "app-manager-${local.cluster_name}-key-${random_id.id.hex}"
    description = "${local.description}"
    owner {
        id = confluent_service_account.app_manager.id
        api_version = confluent_service_account.app_manager.api_version
        kind = confluent_service_account.app_manager.kind
    }
    managed_resource {
        id = confluent_kafka_cluster.default_cluster.id
        api_version = confluent_kafka_cluster.default_cluster.api_version
        kind = confluent_kafka_cluster.default_cluster.kind
        environment {
            id = confluent_environment.default_env.id
        }
    }
    depends_on = [
        confluent_role_binding.app_manager_environment_admin
    ]
}

resource "confluent_api_key" "clients_default_cluster_key" {
    display_name = "clients-${local.cluster_name}-key-${random_id.id.hex}"
    description = "${local.description}"
    owner {
        id = confluent_service_account.clients.id
        api_version = confluent_service_account.clients.api_version
        kind = confluent_service_account.clients.kind
    }
    managed_resource {
        id = confluent_kafka_cluster.default_cluster.id
        api_version = confluent_kafka_cluster.default_cluster.api_version
        kind = confluent_kafka_cluster.default_cluster.kind
        environment {
            id = confluent_environment.default_env.id
        }
    }
    depends_on = [
        confluent_role_binding.clients_cluster_admin
    ]
}