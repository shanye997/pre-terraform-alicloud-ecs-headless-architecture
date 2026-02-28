# Complete Example

This example demonstrates how to use the Headless Architecture Solution module to deploy a complete frontend-backend separation architecture on Alibaba Cloud ECS.

## Architecture Overview

This example creates:

- **VPC**: A virtual private cloud with CIDR block `192.168.0.0/16`
- **VSwitches**: Four VSwitches across two availability zones
  - `vswitch_1` and `vswitch_2` in the first zone
  - `vswitch_3` and `vswitch_4` in the second zone
- **Security Groups**: Separate security groups for frontend and backend instances
- **ECS Instances**: Four ECS instances
  - Two frontend instances (`ecs_fe_1`, `ecs_fe_3`) running Nginx
  - Two backend instances (`ecs_be_2`, `ecs_be_4`) running Java backend services
- **ALB Load Balancers**: 
  - Frontend ALB with public internet access
  - Backend ALB for internal communication
- **Auto Deployment**: Automated deployment scripts for both frontend and backend services

## Prerequisites

1. **Alibaba Cloud Account**: You need an active Alibaba Cloud account with appropriate permissions
2. **Terraform**: Install Terraform >= 1.0
3. **Alibaba Cloud CLI**: Configure your credentials using `aliyun configure` or environment variables

## Usage

1. **Clone the repository** (if using as a module):
   ```bash
   git clone <repository-url>
   cd <repository-name>/examples/complete
   ```

2. **Set required variables**:
   Create a `terraform.tfvars` file:
   ```hcl
   region                = "cn-hangzhou"
   ecs_instance_password = "YourSecurePassword123!"
   ```

3. **Initialize Terraform**:
   ```bash
   terraform init
   ```

4. **Plan the deployment**:
   ```bash
   terraform plan
   ```

5. **Apply the configuration**:
   ```bash
   terraform apply
   ```

6. **Access the application**:
   After deployment, use the `web_url` output to access the web application.

## Configuration

### Required Variables

- `ecs_instance_password`: Password for ECS instances (must be 8-30 characters with at least three types: uppercase, lowercase, numbers, special characters)

### Optional Variables

- `region`: Alibaba Cloud region (default: `cn-hangzhou`)
- `common_name_suffix`: Suffix for resource names (default: `example`)
- `vpc_cidr_block`: VPC CIDR block (default: `192.168.0.0/16`)
- `instance_type`: ECS instance type (default: `ecs.t6-c1m2.large`)

See `variables.tf` for all available configuration options.

## Outputs

- `web_url`: The public URL to access the web application
- `vpc_id`: ID of the created VPC
- `ecs_instance_ids`: IDs of all ECS instances
- `frontend_alb_dns_name`: DNS name of the frontend load balancer
- `backend_alb_dns_name`: DNS name of the backend load balancer

## Architecture Features

- **High Availability**: Resources are distributed across multiple availability zones
- **Load Balancing**: ALB distributes traffic across multiple instances
- **Security**: Separate security groups with minimal required permissions
- **Auto Deployment**: Automated setup of frontend (Nginx) and backend (Java) services
- **Scalable**: Easy to modify instance counts and types

## Cleanup

To destroy the created resources:

```bash
terraform destroy
```

## Notes

- The deployment process includes automatic installation and configuration of services
- Frontend instances will have Nginx configured to proxy API requests to the backend
- Backend instances will have Java services automatically started
- All resources are tagged for easy identification and management

## Troubleshooting

1. **Instance Password Requirements**: Ensure the password meets Alibaba Cloud requirements
2. **Region Availability**: Verify that the selected region supports the required instance types
3. **Quota Limits**: Check your account quotas for ECS instances and other resources
4. **Network Configuration**: Ensure security group rules allow necessary traffic