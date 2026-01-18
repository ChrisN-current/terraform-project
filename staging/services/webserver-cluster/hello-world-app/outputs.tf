output "lb_dns_name" {
  value       = module.hello_world_app.dns_name
  description = "The DNS name of the load balancer."
}