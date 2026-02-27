Alibaba Cloud ECS Headless Architecture Terraform Module

================================================

# terraform-alicloud-ecs-headless-architecture

English | [简体中文](https://github.com/alibabacloud-automation/terraform-alicloud-ecs-headless-architecture/blob/main/README-CN.md)

Terraform module which creates a complete headless architecture solution on Alibaba Cloud ECS. This module implements the [The Headless Architecture Solution of Alibaba Cloud(ECS)](https://www.aliyun.com/solution/tech-solution-deploy/2867383) which provides a comprehensive frontend-backend separation architecture with automated deployment, load balancing, and high availability across multiple zones.

The solution creates a scalable web application infrastructure with separate frontend (Nginx) and backend (Java) services, distributed across multiple availability zones with Application Load Balancer (ALB) for traffic distribution and automated service deployment through ECS commands.

## Usage

This module creates a complete headless architecture with frontend and backend separation, including VPC, VSwitches, security groups, ECS instances, ALB load balancers, and automated service deployment.

```terraform
data "alicloud_zones" "default" {
  available_disk_category     = "cloud_essd"
  available_resource_creation = "VSwitch"
}

data "alicloud_images" "default" {
  name_regex  = "^aliyun_3_x64_20G_alibase_.*"
  most_recent = true
  owners      = "system"
}

module "headless_architecture" {
  source = "alibabacloud-automation/ecs-headless-architecture/alicloud"

  vpc_config = {
    cidr_block = "192.168.0.0/16"
  }

  frontend_vswitches_config = {
    frontend_1 = {
      cidr_block = "192.168.1.0/24"
      zone_id    = data.alicloud_zones.default.zones[0].id
    }
    frontend_2 = {
      cidr_block = "192.168.3.0/24"
      zone_id    = data.alicloud_zones.default.zones[1].id
    }
  }

  backend_vswitches_config = {
    backend_1 = {
      cidr_block = "192.168.2.0/24"
      zone_id    = data.alicloud_zones.default.zones[0].id
    }
    backend_2 = {
      cidr_block = "192.168.4.0/24"
      zone_id    = data.alicloud_zones.default.zones[1].id
    }
  }

  security_groups_config = {
    frontend = {
      rules = [
        {
          type        = "ingress"
          ip_protocol = "tcp"
          nic_type    = "intranet"
          policy      = "accept"
          port_range  = "80/80"
          priority    = 1
          cidr_ip     = "0.0.0.0/0"
        }
      ]
    }
    backend = {
      rules = [
        {
          type        = "ingress"
          ip_protocol = "tcp"
          nic_type    = "intranet"
          policy      = "accept"
          port_range  = "8080/8080"
          priority    = 1
          cidr_ip     = "192.168.0.0/16"
        }
      ]
    }
  }

  instance_config = {
    image_id                   = data.alicloud_images.default.images[0].id
    instance_type              = "ecs.t6-c1m2.large"
    system_disk_category       = "cloud_essd"
    internet_max_bandwidth_out = 5
  }

  instance_password = "YourPassword123!"
}
```

## Examples

* [Complete Example](https://github.com/alibabacloud-automation/terraform-alicloud-ecs-headless-architecture/tree/main/examples/complete)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_alicloud"></a> [alicloud](#requirement\_alicloud) | >= 1.131.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_alicloud"></a> [alicloud](#provider\_alicloud) | 1.271.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [alicloud_alb_listener.backend_listener](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/alb_listener) | resource |
| [alicloud_alb_listener.frontend_listener](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/alb_listener) | resource |
| [alicloud_alb_load_balancer.backend_alb](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/alb_load_balancer) | resource |
| [alicloud_alb_load_balancer.frontend_alb](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/alb_load_balancer) | resource |
| [alicloud_alb_server_group.backend_server_group](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/alb_server_group) | resource |
| [alicloud_alb_server_group.frontend_server_group](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/alb_server_group) | resource |
| [alicloud_ecs_command.backend_command](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/ecs_command) | resource |
| [alicloud_ecs_command.frontend_command](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/ecs_command) | resource |
| [alicloud_ecs_invocation.backend_invocation](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/ecs_invocation) | resource |
| [alicloud_ecs_invocation.frontend_invocation](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/ecs_invocation) | resource |
| [alicloud_instance.backend_ecs_instances](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/instance) | resource |
| [alicloud_instance.frontend_ecs_instances](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/instance) | resource |
| [alicloud_security_group.security_groups](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/security_group) | resource |
| [alicloud_security_group_rule.security_group_rules](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/security_group_rule) | resource |
| [alicloud_vpc.vpc](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/vpc) | resource |
| [alicloud_vswitch.backend_vswitches](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/vswitch) | resource |
| [alicloud_vswitch.frontend_vswitches](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/vswitch) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backend_alb_config"></a> [backend\_alb\_config](#input\_backend\_alb\_config) | The parameters of backend ALB load balancer. The attributes 'address\_allocated\_mode', 'address\_type', 'load\_balancer\_edition', and 'pay\_type' are required. | <pre>object({<br/>    address_allocated_mode = string<br/>    load_balancer_name     = optional(string, "default-backend-alb")<br/>    address_type           = string<br/>    load_balancer_edition  = string<br/>    pay_type               = string<br/>  })</pre> | <pre>{<br/>  "address_allocated_mode": "Fixed",<br/>  "address_type": "Intranet",<br/>  "load_balancer_edition": "Basic",<br/>  "load_balancer_name": "backend-alb",<br/>  "pay_type": "PayAsYouGo"<br/>}</pre> | no |
| <a name="input_backend_command_config"></a> [backend\_command\_config](#input\_backend\_command\_config) | The parameters of backend ECS command. | <pre>object({<br/>    name        = optional(string, "command-start-backend")<br/>    working_dir = optional(string, "/root")<br/>    type        = optional(string, "RunShellScript")<br/>    timeout     = optional(number, 3600)<br/>  })</pre> | `{}` | no |
| <a name="input_backend_listener_config"></a> [backend\_listener\_config](#input\_backend\_listener\_config) | The parameters of backend ALB listener. The attributes 'listener\_protocol', 'listener\_port', and 'default\_action\_type' are required. | <pre>object({<br/>    listener_protocol   = string<br/>    listener_port       = number<br/>    default_action_type = string<br/>  })</pre> | <pre>{<br/>  "default_action_type": "ForwardGroup",<br/>  "listener_port": 8080,<br/>  "listener_protocol": "HTTP"<br/>}</pre> | no |
| <a name="input_backend_server_group_config"></a> [backend\_server\_group\_config](#input\_backend\_server\_group\_config) | The parameters of backend server group. The attributes 'protocol', 'server\_group\_type', 'sticky\_session\_enabled', and 'health\_check\_enabled' are required. | <pre>object({<br/>    server_group_name      = optional(string, "default-backend-server-group")<br/>    protocol               = string<br/>    server_group_type      = string<br/>    sticky_session_enabled = bool<br/>    health_check_enabled   = bool<br/>  })</pre> | <pre>{<br/>  "health_check_enabled": false,<br/>  "protocol": "HTTP",<br/>  "server_group_name": "backend-server-group",<br/>  "server_group_type": "Instance",<br/>  "sticky_session_enabled": false<br/>}</pre> | no |
| <a name="input_backend_vswitches_config"></a> [backend\_vswitches\_config](#input\_backend\_vswitches\_config) | Configuration for backend VSwitches. Each key represents a unique identifier for the VSwitch. The attributes 'cidr\_block' and 'zone\_id' are required. | <pre>map(object({<br/>    cidr_block   = string<br/>    zone_id      = string<br/>    vswitch_name = optional(string, "default-backend-vswitch")<br/>  }))</pre> | `{}` | no |
| <a name="input_custom_backend_command_script"></a> [custom\_backend\_command\_script](#input\_custom\_backend\_command\_script) | Custom backend ECS command script. If not provided, the default script will be used. | `string` | `null` | no |
| <a name="input_custom_frontend_command_script"></a> [custom\_frontend\_command\_script](#input\_custom\_frontend\_command\_script) | Custom frontend ECS command script. If not provided, the default script will be used. | `string` | `null` | no |
| <a name="input_frontend_alb_config"></a> [frontend\_alb\_config](#input\_frontend\_alb\_config) | The parameters of frontend ALB load balancer. The attributes 'address\_allocated\_mode', 'address\_type', 'load\_balancer\_edition', and 'pay\_type' are required. | <pre>object({<br/>    address_allocated_mode = string<br/>    load_balancer_name     = optional(string, "default-frontend-alb")<br/>    address_type           = string<br/>    load_balancer_edition  = string<br/>    pay_type               = string<br/>  })</pre> | <pre>{<br/>  "address_allocated_mode": "Fixed",<br/>  "address_type": "Internet",<br/>  "load_balancer_edition": "Basic",<br/>  "load_balancer_name": "frontend-alb",<br/>  "pay_type": "PayAsYouGo"<br/>}</pre> | no |
| <a name="input_frontend_command_config"></a> [frontend\_command\_config](#input\_frontend\_command\_config) | The parameters of frontend ECS command. | <pre>object({<br/>    name        = optional(string, "command-start-frontend")<br/>    working_dir = optional(string, "/root")<br/>    type        = optional(string, "RunShellScript")<br/>    timeout     = optional(number, 3600)<br/>  })</pre> | `{}` | no |
| <a name="input_frontend_listener_config"></a> [frontend\_listener\_config](#input\_frontend\_listener\_config) | The parameters of frontend ALB listener. The attributes 'listener\_protocol', 'listener\_port', and 'default\_action\_type' are required. | <pre>object({<br/>    listener_protocol   = string<br/>    listener_port       = number<br/>    default_action_type = string<br/>  })</pre> | <pre>{<br/>  "default_action_type": "ForwardGroup",<br/>  "listener_port": 80,<br/>  "listener_protocol": "HTTP"<br/>}</pre> | no |
| <a name="input_frontend_server_group_config"></a> [frontend\_server\_group\_config](#input\_frontend\_server\_group\_config) | The parameters of frontend server group. The attributes 'protocol', 'server\_group\_type', 'sticky\_session\_enabled', and 'health\_check\_enabled' are required. | <pre>object({<br/>    server_group_name      = optional(string, "default-frontend-server-group")<br/>    protocol               = string<br/>    server_group_type      = string<br/>    sticky_session_enabled = bool<br/>    health_check_enabled   = bool<br/>  })</pre> | <pre>{<br/>  "health_check_enabled": false,<br/>  "protocol": "HTTP",<br/>  "server_group_name": "frontend-server-group",<br/>  "server_group_type": "Instance",<br/>  "sticky_session_enabled": false<br/>}</pre> | no |
| <a name="input_frontend_vswitches_config"></a> [frontend\_vswitches\_config](#input\_frontend\_vswitches\_config) | Configuration for frontend VSwitches. Each key represents a unique identifier for the VSwitch. The attributes 'cidr\_block' and 'zone\_id' are required. | <pre>map(object({<br/>    cidr_block   = string<br/>    zone_id      = string<br/>    vswitch_name = optional(string, "default-frontend-vswitch")<br/>  }))</pre> | `{}` | no |
| <a name="input_instance_config"></a> [instance\_config](#input\_instance\_config) | The parameters of ECS instance. The attributes 'image\_id', 'instance\_type', 'system\_disk\_category', and 'internet\_max\_bandwidth\_out' are required. | <pre>object({<br/>    image_id                   = string<br/>    instance_type              = string<br/>    system_disk_category       = string<br/>    internet_max_bandwidth_out = number<br/>  })</pre> | n/a | yes |
| <a name="input_instance_password"></a> [instance\_password](#input\_instance\_password) | The password for ECS instances. Must be 8-30 characters long and contain at least three of the following: uppercase letters, lowercase letters, numbers, and special characters. | `string` | n/a | yes |
| <a name="input_security_groups_config"></a> [security\_groups\_config](#input\_security\_groups\_config) | Configuration for security groups. Each key represents a unique identifier for the security group, and rules are nested within each group. | <pre>map(object({<br/>    security_group_name = optional(string, "default-sg")<br/>    rules = optional(list(object({<br/>      type        = string<br/>      ip_protocol = string<br/>      nic_type    = string<br/>      policy      = string<br/>      port_range  = string<br/>      priority    = number<br/>      cidr_ip     = string<br/>    })), [])<br/>  }))</pre> | `{}` | no |
| <a name="input_vpc_config"></a> [vpc\_config](#input\_vpc\_config) | The parameters of VPC. The attribute 'cidr\_block' is required. | <pre>object({<br/>    cidr_block = string<br/>    vpc_name   = optional(string, "default-vpc")<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backend_alb_dns_name"></a> [backend\_alb\_dns\_name](#output\_backend\_alb\_dns\_name) | The DNS name of the backend ALB load balancer. |
| <a name="output_backend_alb_id"></a> [backend\_alb\_id](#output\_backend\_alb\_id) | The ID of the backend ALB load balancer. |
| <a name="output_backend_command_id"></a> [backend\_command\_id](#output\_backend\_command\_id) | The ID of the backend ECS command. |
| <a name="output_backend_ecs_instance_ids"></a> [backend\_ecs\_instance\_ids](#output\_backend\_ecs\_instance\_ids) | The IDs of the backend ECS instances. |
| <a name="output_backend_ecs_instance_private_ips"></a> [backend\_ecs\_instance\_private\_ips](#output\_backend\_ecs\_instance\_private\_ips) | The private IP addresses of the backend ECS instances. |
| <a name="output_backend_ecs_instance_public_ips"></a> [backend\_ecs\_instance\_public\_ips](#output\_backend\_ecs\_instance\_public\_ips) | The public IP addresses of the backend ECS instances. |
| <a name="output_backend_listener_id"></a> [backend\_listener\_id](#output\_backend\_listener\_id) | The ID of the backend ALB listener. |
| <a name="output_backend_server_group_id"></a> [backend\_server\_group\_id](#output\_backend\_server\_group\_id) | The ID of the backend server group. |
| <a name="output_backend_vswitch_ids"></a> [backend\_vswitch\_ids](#output\_backend\_vswitch\_ids) | The IDs of the backend VSwitches. |
| <a name="output_frontend_alb_dns_name"></a> [frontend\_alb\_dns\_name](#output\_frontend\_alb\_dns\_name) | The DNS name of the frontend ALB load balancer. |
| <a name="output_frontend_alb_id"></a> [frontend\_alb\_id](#output\_frontend\_alb\_id) | The ID of the frontend ALB load balancer. |
| <a name="output_frontend_command_id"></a> [frontend\_command\_id](#output\_frontend\_command\_id) | The ID of the frontend ECS command. |
| <a name="output_frontend_ecs_instance_ids"></a> [frontend\_ecs\_instance\_ids](#output\_frontend\_ecs\_instance\_ids) | The IDs of the frontend ECS instances. |
| <a name="output_frontend_ecs_instance_private_ips"></a> [frontend\_ecs\_instance\_private\_ips](#output\_frontend\_ecs\_instance\_private\_ips) | The private IP addresses of the frontend ECS instances. |
| <a name="output_frontend_ecs_instance_public_ips"></a> [frontend\_ecs\_instance\_public\_ips](#output\_frontend\_ecs\_instance\_public\_ips) | The public IP addresses of the frontend ECS instances. |
| <a name="output_frontend_listener_id"></a> [frontend\_listener\_id](#output\_frontend\_listener\_id) | The ID of the frontend ALB listener. |
| <a name="output_frontend_server_group_id"></a> [frontend\_server\_group\_id](#output\_frontend\_server\_group\_id) | The ID of the frontend server group. |
| <a name="output_frontend_vswitch_ids"></a> [frontend\_vswitch\_ids](#output\_frontend\_vswitch\_ids) | The IDs of the frontend VSwitches. |
| <a name="output_security_group_ids"></a> [security\_group\_ids](#output\_security\_group\_ids) | The IDs of the security groups. |
| <a name="output_vpc_cidr_block"></a> [vpc\_cidr\_block](#output\_vpc\_cidr\_block) | The CIDR block of the VPC. |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC. |
| <a name="output_web_url"></a> [web\_url](#output\_web\_url) | The URL of the web application. |
<!-- END_TF_DOCS -->

## Submit Issues

If you have any problems when using this module, please opening
a [provider issue](https://github.com/aliyun/terraform-provider-alicloud/issues/new) and let us know.

**Note:** There does not recommend opening an issue on this repo.

## Authors

Created and maintained by Alibaba Cloud Terraform Team(terraform@alibabacloud.com).

## License

MIT Licensed. See LICENSE for full details.

## Reference

* [Terraform-Provider-Alicloud Github](https://github.com/aliyun/terraform-provider-alicloud)
* [Terraform-Provider-Alicloud Release](https://releases.hashicorp.com/terraform-provider-alicloud/)
* [Terraform-Provider-Alicloud Docs](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs)