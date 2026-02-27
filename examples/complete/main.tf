# Configure the Alicloud Provider
provider "alicloud" {
  region = var.region
}

# Get available zones for the current region
data "alicloud_zones" "default" {
  available_disk_category     = "cloud_essd"
  available_resource_creation = "VSwitch"
  available_instance_type     = var.instance_type
}

# Get available images for ECS instances
data "alicloud_images" "default" {
  name_regex  = "^aliyun_3_x64_20G_alibase_.*"
  most_recent = true
  owners      = "system"
}

# Call the headless architecture module
module "headless_architecture" {
  source = "../../"

  vpc_config = {
    cidr_block = var.vpc_cidr_block
    vpc_name   = var.vpc_name
  }

  frontend_vswitches_config = {
    vswitch_1 = {
      cidr_block   = var.vswitch_1_cidr_block
      zone_id      = data.alicloud_zones.default.zones[0].id
      vswitch_name = var.vswitch_1_name
    }
    vswitch_3 = {
      cidr_block   = var.vswitch_3_cidr_block
      zone_id      = data.alicloud_zones.default.zones[1].id
      vswitch_name = var.vswitch_3_name
    }
  }

  backend_vswitches_config = {
    vswitch_2 = {
      cidr_block   = var.vswitch_2_cidr_block
      zone_id      = data.alicloud_zones.default.zones[0].id
      vswitch_name = var.vswitch_2_name
    }
    vswitch_4 = {
      cidr_block   = var.vswitch_4_cidr_block
      zone_id      = data.alicloud_zones.default.zones[1].id
      vswitch_name = var.vswitch_4_name
    }
  }

  security_groups_config = {
    frontend = {
      security_group_name = var.frontend_security_group_name
      rules = [
        {
          type        = "ingress"
          ip_protocol = "tcp"
          nic_type    = "intranet"
          policy      = "accept"
          port_range  = "22/22"
          priority    = 1
          cidr_ip     = "192.168.0.0/16"
        },
        {
          type        = "ingress"
          ip_protocol = "tcp"
          nic_type    = "intranet"
          policy      = "accept"
          port_range  = "80/80"
          priority    = 1
          cidr_ip     = "192.168.0.0/16"
        }
      ]
    }
    backend = {
      security_group_name = var.backend_security_group_name
      rules = [
        {
          type        = "ingress"
          ip_protocol = "tcp"
          nic_type    = "intranet"
          policy      = "accept"
          port_range  = "22/22"
          priority    = 1
          cidr_ip     = "192.168.0.0/16"
        },
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
    instance_type              = var.instance_type
    system_disk_category       = var.system_disk_category
    internet_max_bandwidth_out = var.internet_max_bandwidth_out
  }

  instance_password = var.ecs_instance_password

}

resource "alicloud_alb_load_balancer_security_group_attachment" "default" {
  load_balancer_id  = module.headless_architecture.frontend_alb_id
  security_group_id = module.headless_architecture.security_group_ids["frontend"]
}
