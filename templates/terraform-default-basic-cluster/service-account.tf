resource "confluent_service_account" "app_manager" {
    # TODO I believe this UUID will cause this to be recreated every plan/apply
    display_name = "app-manager-${substr(uuid(),0,8)}"
    description = "Basic barebones cluster config with Terraform"
}

resource "confluent_service_account" "clients" {
    # TODO I believe this UUID will cause this to be recreated every plan/apply
    display_name = "client-${substr(uuid(),0,8)}"
    description = "Basic barebones cluster config with Terraform"
}