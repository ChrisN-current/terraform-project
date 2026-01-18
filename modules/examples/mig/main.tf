data "terraform_remote_state" "db" {
  backend = "gcs"
  config = {
    bucket = var.db_remote_state_bucket
    prefix = "CHRIS-MYSQL"
  }
}

module "mig" {
  source = "../../modules/cluster/mig-rolling-deploy"

  gcp_project  = var.gcp_project
  zone         = var.zone
  cluster_name = var.cluster_name

  machine_type = var.machine_type
  source_image = var.server_image

  server_port = var.server_port

  user_data = templatefile("${path.module}/user-data.sh", {
    db_username = data.terraform_remote_state.db.outputs.db_username
    db_password = data.terraform_remote_state.db.outputs.db_password
    db_name     = data.terraform_remote_state.db.outputs.db_name
    server_port = var.server_port
    server_text = var.server_text
  })

  target_size        = var.target_size
  enable_autoscaling = var.enable_autoscaling
  min_replicas       = var.min_replicas
  max_replicas       = var.max_replicas

  scheduler_region          = var.scheduler_region
  scheduler_service_account = var.scheduler_service_account
  scale_up_time             = var.scale_up_time
  scale_up_size             = var.scale_up_size
  scale_down_time           = var.scale_down_time
  scale_down_size           = var.scale_down_size

  network    = var.network
  subnetwork = var.subnetwork
}

module "http_lb" {
  source = "../../modules/networking/http-lb"

  gcp_project = var.gcp_project
  lb_name     = var.cluster_name

  # Either pass these:
  zone     = var.zone
  mig_name = module.mig.mig_name

  health_check_self_link = module.mig.health_check_self_link
}

resource "google_dns_record_set" "app_record" {
  name         = "chris-terraform-project.com."
  managed_zone = "chris-terraform-project-com"
  type         = "A"
  ttl          = 300
  rrdatas      = [module.http_lb.lb_ip]
}
