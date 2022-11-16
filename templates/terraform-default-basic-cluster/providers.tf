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