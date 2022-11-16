resource "confluent_api_key" "app_manager_default_cluster_key" {
    display_name = "app-manager-default-cluster-key-${substr(uuid(),0,8)}"
    description = "Basic barebones cluster config with Terraform"
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
    display_name = "clients-default-cluster-key-${substr(uuid(),0,8)}"
    description = "Basic barebones cluster config with Terraform"
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