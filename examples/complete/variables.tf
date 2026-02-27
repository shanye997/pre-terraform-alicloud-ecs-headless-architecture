variable "region" {
  description = "The Alibaba Cloud region to deploy resources in."
  type        = string
  default     = "cn-hangzhou"
}

variable "vpc_cidr_block" {
  description = "The CIDR block of the VPC."
  type        = string
  default     = "192.168.0.0/16"
}

variable "vpc_name" {
  description = "The name of the VPC."
  type        = string
  default     = "vpc-headless-arch-example"
}

variable "vswitch_1_cidr_block" {
  description = "The CIDR block of VSwitch 1."
  type        = string
  default     = "192.168.1.0/24"
}

variable "vswitch_1_name" {
  description = "The name of VSwitch 1."
  type        = string
  default     = "vswitch-1-example"
}

variable "vswitch_2_cidr_block" {
  description = "The CIDR block of VSwitch 2."
  type        = string
  default     = "192.168.2.0/24"
}

variable "vswitch_2_name" {
  description = "The name of VSwitch 2."
  type        = string
  default     = "vswitch-2-example"
}

variable "vswitch_3_cidr_block" {
  description = "The CIDR block of VSwitch 3."
  type        = string
  default     = "192.168.3.0/24"
}

variable "vswitch_3_name" {
  description = "The name of VSwitch 3."
  type        = string
  default     = "vswitch-3-example"
}

variable "vswitch_4_cidr_block" {
  description = "The CIDR block of VSwitch 4."
  type        = string
  default     = "192.168.4.0/24"
}

variable "vswitch_4_name" {
  description = "The name of VSwitch 4."
  type        = string
  default     = "vswitch-4-example"
}

variable "frontend_security_group_name" {
  description = "The name of the frontend security group."
  type        = string
  default     = "sg-fe-example"
}

variable "backend_security_group_name" {
  description = "The name of the backend security group."
  type        = string
  default     = "sg-be-example"
}

variable "instance_type" {
  description = "The type of ECS instance."
  type        = string
  default     = "ecs.t6-c1m2.large"
}

variable "system_disk_category" {
  description = "The category of the system disk."
  type        = string
  default     = "cloud_essd"
}

variable "ecs_instance_password" {
  description = "The password for ECS instances. Must be 8-30 characters long and contain at least three of the following: uppercase letters, lowercase letters, numbers, and special characters."
  type        = string
  sensitive   = true
}

variable "internet_max_bandwidth_out" {
  description = "The maximum outbound bandwidth for ECS instances."
  type        = number
  default     = 5
}

