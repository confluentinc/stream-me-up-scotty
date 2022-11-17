# # Passed by providing the env var TF_VAR_GCP_PROJECT
# variable "GCP_PROJECT" {
#   type = string
# }
# # Passed by providing the env var TF_VAR_GCP_PROJECT
# variable "GCP_CREDENTIALS" {
#   type = string
# }

provider "google" {
    project = var.GCP_PROJECT
    region  = "us-east1"
    zone    = "us-east1-c"
    credentials = var.GCP_CREDENTIALS 
}
data "google_compute_network" "default" {
    name = "default"
}
resource "google_compute_firewall" "postgres" {
    name = "rt-dwh-postgres-firewall"
    network = data.google_compute_network.default.name
    source_ranges = [ "0.0.0.0/0" ]
    direction = "INGRESS"
    allow {
        protocol = "tcp"
        ports = [ "5432" ]
    }
}
resource "google_compute_firewall" "mysql" {
    name = "rt-dwh-mysql-firewall"
    network = data.google_compute_network.default.name
    source_ranges = [ "0.0.0.0/0" ]
    direction = "INGRESS"
    allow {
        protocol = "tcp"
        ports = [ "3306" ]
    }
}
data "google_compute_image" "os" {
    project = "centos-cloud"
    family = "centos-7"
}
resource "google_compute_instance" "postgres" {
    name = "rt-dwh-postgres"
    machine_type = "e2-standard-2"
    boot_disk {
        initialize_params {
            image = data.google_compute_image.os.self_link
        }
    }
    network_interface {
        network = "default"
        access_config {}
    }
    metadata = {
        startup-script = file("../scripts/pg_commands.sh")
    }
}
resource "google_compute_instance" "mysql" {
    name = "rt-dwh-mysql"
    machine_type = "e2-standard-2"
    boot_disk {
        initialize_params {
            image =data.google_compute_image.os.self_link
        }
    }
    network_interface {
        network = "default"
        access_config {}
    }
    metadata = {
        startup-script = file("../scripts/ms_commands.sh")
    }
}
