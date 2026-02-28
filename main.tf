# Local variables for complex logic
locals {
  # Flatten security group rules for iteration
  security_group_rules = flatten([
    for sg_key, sg_config in var.security_groups_config : [
      for rule_index, rule_config in sg_config.rules : {
        key                = "${sg_key}_${rule_index}"
        security_group_key = sg_key
        type               = rule_config.type
        ip_protocol        = rule_config.ip_protocol
        nic_type           = rule_config.nic_type
        policy             = rule_config.policy
        port_range         = rule_config.port_range
        priority           = rule_config.priority
        cidr_ip            = rule_config.cidr_ip
      }
    ]
  ])

  # Default backend ECS command script
  default_backend_command_script = <<-EOF
#!/bin/bash

# Install and start Java backend
curl -fsSL https://help-static-aliyun-doc.aliyuncs.com/install-script/frontend-backend-separation-architecture/java.sh | sudo bash
EOF

  # Default frontend ECS command script  
  default_frontend_command_script = <<-EOF
#!/bin/bash

# Install frontend
sudo yum install -y nginx

# Download frontend resources
sudo yum install -y unzip
sudo wget -O $HOME/pages.zip https://help-static-aliyun-doc.aliyuncs.com/install-script/frontend-backend-separation-architecture/pages.zip
sudo unzip -o $HOME/pages.zip 
sudo chmod -R a+rx $HOME/dist/ 
sudo cp -r $HOME/dist/* /usr/share/nginx/html

# Config frontend
cat << EOT > /etc/nginx/nginx.conf
# For more information on configuration, see:
#   * Official English Documentation: http://nginx.org/en/docs/
#   * Official Russian Documentation: http://nginx.org/ru/docs/

user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

# Load dynamic modules. See /usr/share/doc/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 4096;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    # Load modular configuration files from the /etc/nginx/conf.d directory.
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    # for more information.
    include /etc/nginx/conf.d/*.conf;

    server {
        listen       80;
        listen       [::]:80;
        server_name  _;
        root         /usr/share/nginx/html;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        # Static resource location for client page access
        location / {
            root /usr/share/nginx/html; 
            index index.html;
        }
        
        # Configure request forwarding rules
        location /api/ {
            proxy_pass  http://${alicloud_alb_load_balancer.backend_alb.dns_name}:8080/api/;
        }

        error_page 404 /404.html;
            location = /40x.html {
        }

        error_page 500 502 503 504 /50x.html;
            location = /50x.html {
        }
    }
}
EOT

# Start frontend
sudo systemctl start nginx
sudo systemctl enable nginx
EOF
}

# Create VPC
resource "alicloud_vpc" "vpc" {
  cidr_block = var.vpc_config.cidr_block
  vpc_name   = var.vpc_config.vpc_name
}

# Create frontend VSwitches
resource "alicloud_vswitch" "frontend_vswitches" {
  for_each = var.frontend_vswitches_config

  vpc_id       = alicloud_vpc.vpc.id
  cidr_block   = each.value.cidr_block
  zone_id      = each.value.zone_id
  vswitch_name = each.value.vswitch_name
}

# Create backend VSwitches
resource "alicloud_vswitch" "backend_vswitches" {
  for_each = var.backend_vswitches_config

  vpc_id       = alicloud_vpc.vpc.id
  cidr_block   = each.value.cidr_block
  zone_id      = each.value.zone_id
  vswitch_name = each.value.vswitch_name
}

# Create security groups
resource "alicloud_security_group" "security_groups" {
  for_each = var.security_groups_config

  vpc_id              = alicloud_vpc.vpc.id
  security_group_name = each.value.security_group_name
}

# Create security group rules
resource "alicloud_security_group_rule" "security_group_rules" {
  for_each = { for rule in local.security_group_rules : rule.key => rule }

  type              = each.value.type
  ip_protocol       = each.value.ip_protocol
  nic_type          = each.value.nic_type
  policy            = each.value.policy
  port_range        = each.value.port_range
  priority          = each.value.priority
  security_group_id = alicloud_security_group.security_groups[each.value.security_group_key].id
  cidr_ip           = each.value.cidr_ip
}

# Create frontend ECS instances
resource "alicloud_instance" "frontend_ecs_instances" {
  for_each = alicloud_vswitch.frontend_vswitches

  instance_name              = each.value.vswitch_name
  image_id                   = var.instance_config.image_id
  instance_type              = var.instance_config.instance_type
  system_disk_category       = var.instance_config.system_disk_category
  security_groups            = [alicloud_security_group.security_groups["frontend"].id]
  vswitch_id                 = each.value.id
  password                   = var.instance_password
  internet_max_bandwidth_out = var.instance_config.internet_max_bandwidth_out
}

# Create backend ECS instances
resource "alicloud_instance" "backend_ecs_instances" {
  for_each = alicloud_vswitch.backend_vswitches

  instance_name              = each.value.vswitch_name
  image_id                   = var.instance_config.image_id
  instance_type              = var.instance_config.instance_type
  system_disk_category       = var.instance_config.system_disk_category
  security_groups            = [alicloud_security_group.security_groups["backend"].id]
  vswitch_id                 = each.value.id
  password                   = var.instance_password
  internet_max_bandwidth_out = var.instance_config.internet_max_bandwidth_out
}

# Create ECS commands for backend
resource "alicloud_ecs_command" "backend_command" {
  name            = var.backend_command_config.name
  command_content = base64encode(var.custom_backend_command_script != null ? var.custom_backend_command_script : local.default_backend_command_script)
  working_dir     = var.backend_command_config.working_dir
  type            = var.backend_command_config.type
  timeout         = var.backend_command_config.timeout
}

# Create ECS commands for frontend
resource "alicloud_ecs_command" "frontend_command" {
  name            = var.frontend_command_config.name
  command_content = base64encode(var.custom_frontend_command_script != null ? var.custom_frontend_command_script : local.default_frontend_command_script)
  working_dir     = var.frontend_command_config.working_dir
  type            = var.frontend_command_config.type
  timeout         = var.frontend_command_config.timeout
}

# Execute ECS commands on backend instances
resource "alicloud_ecs_invocation" "backend_invocation" {
  instance_id = [for key, instance in alicloud_instance.backend_ecs_instances : instance.id]
  command_id  = alicloud_ecs_command.backend_command.id

  timeouts {
    create = "15m"
  }

}

# Execute ECS commands on frontend instances
resource "alicloud_ecs_invocation" "frontend_invocation" {
  instance_id = [for key, instance in alicloud_instance.frontend_ecs_instances : instance.id]
  command_id  = alicloud_ecs_command.frontend_command.id

  timeouts {
    create = "15m"
  }

  depends_on = [alicloud_ecs_invocation.backend_invocation]
}

# Create backend ALB load balancer
resource "alicloud_alb_load_balancer" "backend_alb" {
  address_allocated_mode = var.backend_alb_config.address_allocated_mode
  load_balancer_name     = var.backend_alb_config.load_balancer_name
  vpc_id                 = alicloud_vpc.vpc.id
  address_type           = var.backend_alb_config.address_type
  load_balancer_edition  = var.backend_alb_config.load_balancer_edition

  load_balancer_billing_config {
    pay_type = var.backend_alb_config.pay_type
  }

  dynamic "zone_mappings" {
    for_each = alicloud_vswitch.backend_vswitches
    content {
      zone_id    = zone_mappings.value.zone_id
      vswitch_id = zone_mappings.value.id
    }
  }
}

# Create frontend ALB load balancer
resource "alicloud_alb_load_balancer" "frontend_alb" {
  address_allocated_mode = var.frontend_alb_config.address_allocated_mode
  load_balancer_name     = var.frontend_alb_config.load_balancer_name
  vpc_id                 = alicloud_vpc.vpc.id
  address_type           = var.frontend_alb_config.address_type
  load_balancer_edition  = var.frontend_alb_config.load_balancer_edition

  load_balancer_billing_config {
    pay_type = var.frontend_alb_config.pay_type
  }

  dynamic "zone_mappings" {
    for_each = alicloud_vswitch.frontend_vswitches
    content {
      zone_id    = zone_mappings.value.zone_id
      vswitch_id = zone_mappings.value.id
    }
  }
}

# Create backend server group
resource "alicloud_alb_server_group" "backend_server_group" {
  server_group_name = var.backend_server_group_config.server_group_name
  protocol          = var.backend_server_group_config.protocol
  vpc_id            = alicloud_vpc.vpc.id
  server_group_type = var.backend_server_group_config.server_group_type

  sticky_session_config {
    sticky_session_enabled = var.backend_server_group_config.sticky_session_enabled
  }

  health_check_config {
    health_check_enabled = var.backend_server_group_config.health_check_enabled
  }

  dynamic "servers" {
    for_each = alicloud_instance.backend_ecs_instances
    content {
      server_type = "Ecs"
      port        = var.backend_listener_config.listener_port
      server_id   = servers.value.id
      server_ip   = servers.value.primary_ip_address
      weight      = 100 / length(alicloud_instance.backend_ecs_instances)
    }
  }
}

# Create frontend server group
resource "alicloud_alb_server_group" "frontend_server_group" {
  server_group_name = var.frontend_server_group_config.server_group_name
  protocol          = var.frontend_server_group_config.protocol
  vpc_id            = alicloud_vpc.vpc.id
  server_group_type = var.frontend_server_group_config.server_group_type

  sticky_session_config {
    sticky_session_enabled = var.frontend_server_group_config.sticky_session_enabled
  }

  health_check_config {
    health_check_enabled = var.frontend_server_group_config.health_check_enabled
  }

  dynamic "servers" {
    for_each = alicloud_instance.frontend_ecs_instances
    content {
      server_type = "Ecs"
      port        = var.frontend_listener_config.listener_port
      server_id   = servers.value.id
      server_ip   = servers.value.primary_ip_address
      weight      = 100 / length(alicloud_instance.frontend_ecs_instances)
    }
  }
}

# Create backend listener
resource "alicloud_alb_listener" "backend_listener" {
  load_balancer_id  = alicloud_alb_load_balancer.backend_alb.id
  listener_protocol = var.backend_listener_config.listener_protocol
  listener_port     = var.backend_listener_config.listener_port

  default_actions {
    type = var.backend_listener_config.default_action_type
    forward_group_config {
      server_group_tuples {
        server_group_id = alicloud_alb_server_group.backend_server_group.id
      }
    }
  }
}

# Create frontend listener
resource "alicloud_alb_listener" "frontend_listener" {
  load_balancer_id  = alicloud_alb_load_balancer.frontend_alb.id
  listener_protocol = var.frontend_listener_config.listener_protocol
  listener_port     = var.frontend_listener_config.listener_port

  default_actions {
    type = var.frontend_listener_config.default_action_type
    forward_group_config {
      server_group_tuples {
        server_group_id = alicloud_alb_server_group.frontend_server_group.id
      }
    }
  }
}