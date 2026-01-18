output "lb_ip" {
  value = module.alb.lb_ip
}

output "mig_name" {
  value = module.asg.mig_name
}