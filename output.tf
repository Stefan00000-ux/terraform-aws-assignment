output "load_balancer_url" {
  description = "The DNS name of the load balancer"
  value       = module.alb.alb_dns_name
}

output "final_vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}