output "vpc_id" {
  description = "The ID of the VPC."
  value       = module.headless_architecture.vpc_id
}

output "frontend_vswitch_ids" {
  description = "The IDs of the frontend VSwitches."
  value       = module.headless_architecture.frontend_vswitch_ids
}

output "backend_vswitch_ids" {
  description = "The IDs of the backend VSwitches."
  value       = module.headless_architecture.backend_vswitch_ids
}

output "security_group_ids" {
  description = "The IDs of the security groups."
  value       = module.headless_architecture.security_group_ids
}

output "frontend_ecs_instance_ids" {
  description = "The IDs of the frontend ECS instances."
  value       = module.headless_architecture.frontend_ecs_instance_ids
}

output "backend_ecs_instance_ids" {
  description = "The IDs of the backend ECS instances."
  value       = module.headless_architecture.backend_ecs_instance_ids
}

output "frontend_ecs_instance_private_ips" {
  description = "The private IP addresses of the frontend ECS instances."
  value       = module.headless_architecture.frontend_ecs_instance_private_ips
}

output "backend_ecs_instance_private_ips" {
  description = "The private IP addresses of the backend ECS instances."
  value       = module.headless_architecture.backend_ecs_instance_private_ips
}

output "backend_alb_dns_name" {
  description = "The DNS name of the backend ALB load balancer."
  value       = module.headless_architecture.backend_alb_dns_name
}

output "frontend_alb_dns_name" {
  description = "The DNS name of the frontend ALB load balancer."
  value       = module.headless_architecture.frontend_alb_dns_name
}

output "web_url" {
  description = "The URL of the web application."
  value       = module.headless_architecture.web_url
}

output "backend_server_group_id" {
  description = "The ID of the backend server group."
  value       = module.headless_architecture.backend_server_group_id
}

output "frontend_server_group_id" {
  description = "The ID of the frontend server group."
  value       = module.headless_architecture.frontend_server_group_id
}