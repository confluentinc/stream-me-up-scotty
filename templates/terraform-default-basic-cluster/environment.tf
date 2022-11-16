resource "confluent_environment" "default_env" {
    # TODO I believe this UUID will cause this to be recreated every plan/apply
    display_name = "basic-cluster-env-${substr(uuid(),0,8)}"
    lifecycle {
        prevent_destroy = false
    }
}