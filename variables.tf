variable "vpc_config" {
  description = "The parameters of VPC. The attribute 'cidr_block' is required."
  type = object({
    cidr_block = string
    vpc_name   = optional(string, "default-vpc")
  })
}

variable "frontend_vswitches_config" {
  description = "Configuration for frontend VSwitches. Each key represents a unique identifier for the VSwitch. The attributes 'cidr_block' and 'zone_id' are required."
  type = map(object({
    cidr_block   = string
    zone_id      = string
    vswitch_name = optional(string, "default-frontend-vswitch")
  }))
  default = {}
}

variable "backend_vswitches_config" {
  description = "Configuration for backend VSwitches. Each key represents a unique identifier for the VSwitch. The attributes 'cidr_block' and 'zone_id' are required."
  type = map(object({
    cidr_block   = string
    zone_id      = string
    vswitch_name = optional(string, "default-backend-vswitch")
  }))
  default = {}
}

variable "security_groups_config" {
  description = "Configuration for security groups. Each key represents a unique identifier for the security group, and rules are nested within each group."
  type = map(object({
    security_group_name = optional(string, "default-sg")
    rules = optional(list(object({
      type        = string
      ip_protocol = string
      nic_type    = string
      policy      = string
      port_range  = string
      priority    = number
      cidr_ip     = string
    })), [])
  }))
  default = {}
}

variable "instance_config" {
  description = "The parameters of ECS instance. The attributes 'image_id', 'instance_type', 'system_disk_category', and 'internet_max_bandwidth_out' are required."
  type = object({
    image_id                   = string
    instance_type              = string
    system_disk_category       = string
    internet_max_bandwidth_out = number
  })
}

variable "instance_password" {
  description = "The password for ECS instances. Must be 8-30 characters long and contain at least three of the following: uppercase letters, lowercase letters, numbers, and special characters."
  type        = string
  sensitive   = true
}


variable "backend_command_config" {
  description = "The parameters of backend ECS command."
  type = object({
    name        = optional(string, "command-start-backend")
    working_dir = optional(string, "/root")
    type        = optional(string, "RunShellScript")
    timeout     = optional(number, 3600)
  })
  default = {}
}

variable "frontend_command_config" {
  description = "The parameters of frontend ECS command."
  type = object({
    name        = optional(string, "command-start-frontend")
    working_dir = optional(string, "/root")
    type        = optional(string, "RunShellScript")
    timeout     = optional(number, 3600)
  })
  default = {}
}

variable "custom_backend_command_script" {
  description = "Custom backend ECS command script. If not provided, the default script will be used."
  type        = string
  default     = null
}

variable "custom_frontend_command_script" {
  description = "Custom frontend ECS command script. If not provided, the default script will be used."
  type        = string
  default     = null
}

variable "backend_alb_config" {
  description = "The parameters of backend ALB load balancer. The attributes 'address_allocated_mode', 'address_type', 'load_balancer_edition', and 'pay_type' are required."
  type = object({
    address_allocated_mode = string
    load_balancer_name     = optional(string, "default-backend-alb")
    address_type           = string
    load_balancer_edition  = string
    pay_type               = string
  })
  default = {
    address_allocated_mode = "Fixed"
    load_balancer_name     = "backend-alb"
    address_type           = "Intranet"
    load_balancer_edition  = "Basic"
    pay_type               = "PayAsYouGo"
  }
}

variable "frontend_alb_config" {
  description = "The parameters of frontend ALB load balancer. The attributes 'address_allocated_mode', 'address_type', 'load_balancer_edition', and 'pay_type' are required."
  type = object({
    address_allocated_mode = string
    load_balancer_name     = optional(string, "default-frontend-alb")
    address_type           = string
    load_balancer_edition  = string
    pay_type               = string
  })
  default = {
    address_allocated_mode = "Fixed"
    load_balancer_name     = "frontend-alb"
    address_type           = "Internet"
    load_balancer_edition  = "Basic"
    pay_type               = "PayAsYouGo"
  }
}

variable "backend_server_group_config" {
  description = "The parameters of backend server group. The attributes 'protocol', 'server_group_type', 'sticky_session_enabled', and 'health_check_enabled' are required."
  type = object({
    server_group_name      = optional(string, "default-backend-server-group")
    protocol               = string
    server_group_type      = string
    sticky_session_enabled = bool
    health_check_enabled   = bool
  })
  default = {
    server_group_name      = "backend-server-group"
    protocol               = "HTTP"
    server_group_type      = "Instance"
    sticky_session_enabled = false
    health_check_enabled   = false
  }
}

variable "frontend_server_group_config" {
  description = "The parameters of frontend server group. The attributes 'protocol', 'server_group_type', 'sticky_session_enabled', and 'health_check_enabled' are required."
  type = object({
    server_group_name      = optional(string, "default-frontend-server-group")
    protocol               = string
    server_group_type      = string
    sticky_session_enabled = bool
    health_check_enabled   = bool
  })
  default = {
    server_group_name      = "frontend-server-group"
    protocol               = "HTTP"
    server_group_type      = "Instance"
    sticky_session_enabled = false
    health_check_enabled   = false
  }
}

variable "backend_listener_config" {
  description = "The parameters of backend ALB listener. The attributes 'listener_protocol', 'listener_port', and 'default_action_type' are required."
  type = object({
    listener_protocol   = string
    listener_port       = number
    default_action_type = string
  })
  default = {
    listener_protocol   = "HTTP"
    listener_port       = 8080
    default_action_type = "ForwardGroup"
  }
}

variable "frontend_listener_config" {
  description = "The parameters of frontend ALB listener. The attributes 'listener_protocol', 'listener_port', and 'default_action_type' are required."
  type = object({
    listener_protocol   = string
    listener_port       = number
    default_action_type = string
  })
  default = {
    listener_protocol   = "HTTP"
    listener_port       = 80
    default_action_type = "ForwardGroup"
  }
}