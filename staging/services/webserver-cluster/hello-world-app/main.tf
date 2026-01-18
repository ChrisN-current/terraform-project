module "hello_world_app" {
    #TODO replace with actual source path
    source = "git@github.com:foo/modules.git//services/hello-world-app?ref=v1.2.0"

    server_text = "New server text"
    environment = "staging"
    db_remote_state_bucket = "chris-terraform-project-staging-remote-state"
    db_remote_state_key    = "staging/data-stores/mysql/terraform.tfstate"

    instance_type = "e2-micro"
    min_size      = 2
    max_size      = 2
    enable_autoscaling = false
    source_image = "projects/debian-cloud/global/images/family/debian-11"

}