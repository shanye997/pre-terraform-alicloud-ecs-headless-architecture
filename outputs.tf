output "vpc_id" {
  description = "The ID of the VPC."
  value       = alicloud_vpc.vpc.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC."
  value       = alicloud_vpc.vpc.cidr_block
}

output "frontend_vswitch_ids" {
  description = "The IDs of the frontend VSwitches."
  value       = { for k, v in alicloud_vswitch.frontend_vswitches : k => v.id }
}

output "backend_vswitch_ids" {
  description = "The IDs of the backend VSwitches."
  value       = { for k, v in alicloud_vswitch.backend_vswitches : k => v.id }
}

output "security_group_ids" {
  description = "The IDs of the security groups."
  value       = { for k, v in alicloud_security_group.security_groups : k => v.id }
}

output "frontend_ecs_instance_ids" {
  description = "The IDs of the frontend ECS instances."
  value       = { for k, v in alicloud_instance.frontend_ecs_instances : k => v.id }
}

output "backend_ecs_instance_ids" {
  description = "The IDs of the backend ECS instances."
  value       = { for k, v in alicloud_instance.backend_ecs_instances : k => v.id }
}

output "frontend_ecs_instance_private_ips" {
  description = "The private IP addresses of the frontend ECS instances."
  value       = { for k, v in alicloud_instance.frontend_ecs_instances : k => v.primary_ip_address }
}

output "backend_ecs_instance_private_ips" {
  description = "The private IP addresses of the backend ECS instances."
  value       = { for k, v in alicloud_instance.backend_ecs_instances : k => v.primary_ip_address }
}

output "frontend_ecs_instance_public_ips" {
  description = "The public IP addresses of the frontend ECS instances."
  value       = { for k, v in alicloud_instance.frontend_ecs_instances : k => v.public_ip }
}

output "backend_ecs_instance_public_ips" {
  description = "The public IP addresses of the backend ECS instances."
  value       = { for k, v in alicloud_instance.backend_ecs_instances : k => v.public_ip }
}

output "backend_alb_id" {
  description = "The ID of the backend ALB load balancer."
  value       = alicloud_alb_load_balancer.backend_alb.id
}

output "backend_alb_dns_name" {
  description = "The DNS name of the backend ALB load balancer."
  value       = alicloud_alb_load_balancer.backend_alb.dns_name
}

output "frontend_alb_id" {
  description = "The ID of the frontend ALB load balancer."
  value       = alicloud_alb_load_balancer.frontend_alb.id
}

output "frontend_alb_dns_name" {
  description = "The DNS name of the frontend ALB load balancer."
  value       = alicloud_alb_load_balancer.frontend_alb.dns_name
}

output "backend_server_group_id" {
  description = "The ID of the backend server group."
  value       = alicloud_alb_server_group.backend_server_group.id
}

output "frontend_server_group_id" {
  description = "The ID of the frontend server group."
  value       = alicloud_alb_server_group.frontend_server_group.id
}

output "backend_listener_id" {
  description = "The ID of the backend ALB listener."
  value       = alicloud_alb_listener.backend_listener.id
}

output "frontend_listener_id" {
  description = "The ID of the frontend ALB listener."
  value       = alicloud_alb_listener.frontend_listener.id
}

output "web_url" {
  description = "The URL of the web application."
  value       = "http://${alicloud_alb_load_balancer.frontend_alb.dns_name}"
}

output "backend_command_id" {
  description = "The ID of the backend ECS command."
  value       = alicloud_ecs_command.backend_command.id
}

output "frontend_command_id" {
  description = "The ID of the frontend ECS command."
  value       = alicloud_ecs_command.frontend_command.id
}