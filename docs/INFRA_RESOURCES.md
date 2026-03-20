# Infrastructure Resources (AWS)

## Raw list

- Network
  - VPC
  - Internet Gateway for internet access
  - 2 Availability Zones (Data) (HA design)
  - Subnets
    - 2 Public subnets for the Web Tier
    - 2 Public subnets for the App Tier
    - 2 Private subnets for the RDS Multi-AZ deployment
  - Subnet group
  - Route table
    - Routes from all public subnets (4) to IGW
- RDS Multi-AZ (2 AZs) PostgreSQL (18) deployment
- Load Balancing
  - 1 internet-facing ALB for the Web Tier (target group)
    - HTTP listener
    - HTTPS listener
  - 1 internal ALB in between the Web Tier (frontend) and the App Tier (backend)
- Security groups
  - 1 for the Web Tier (ASG)
  - 1 for the App Tier (ASG)
  - 1 for the Data Tier (RDS)
  - 1 for the internet-facing ALB
  - 1 for the internal ALB
- Computing
  - 1 Auto Scaling Group (2 AZ span) for the Web tier
  - 1 Auto Scaling Group (2 AZ span) for the App Tier
- IAM roles and instance profiles
- R53 Type A record
- ACM TLS/SSL Certificate (data)
- SSM Parameters
- ECR repositories

---

## Detailed list

> Special feature: flag `enable-r53` will toggle between these behaviors.

Enabled

- R53 Type A record is created
- HTTPS listener is added
  - Pull ACM Certificate
- HTTP listener redirects to HTTPS
- Access to the app is through the custom FQDN

Disabled

- Access to the app is through the ALB DNS endpoint
- No R53 record
- No HTTPS listener

Resources

Network (terraform\modules\network)

- VPC
- Internet Gateway for internet access
- 2 Availability Zones (Data) (HA design)
- Subnets
  - 2 Public subnets for the Web Tier
  - 2 Public subnets for the App Tier
  - 2 Private subnets for the RDS Multi-AZ deployment
  - Subnet group
    - RDS receives a group, not a list
    - Includes the 2 Private subnets
- Route table
  - Routes from all public subnets (x4) to IGW

RDS (terraform\modules\rds)

- PostgreSQL 18
- Multi-AZ (2 AZs)
- "Free-tier friendly" specs
- Storage scaling enabled
- 20 GB

Load Balancing (terraform\modules\alb)

- 1 internet-facing ALB for the Web Tier (target group)
  - HTTP listener
  - HTTPS listener
- 1 internal ALB in between the Web Tier (frontend) and the App Tier (backend)

Security groups (terraform\modules\security-group)

- 1 for the Web Tier (ASG)
  - Allow inbound traffic from the internet-facing ALB SG
  - Allow outbound traffic to the internal ALB SG
  - Allow outbound traffic to the internet
- 1 for the App Tier (ASG)
  - Allow inbound traffic from the internal ALB SG
    - For CORS-off to be safe the frontend must force `server-side` fetch
  - Allow outbound traffic to the RDS SG
  - Allow outbound traffic to the internet
- 1 for the Data Tier (RDS)
  - Allow inbound traffic from the App Tier SG (RDS Multi-AZ has a single endpoint)
- 1 for the internet-facing ALB
  - Allow inbound internet traffic (HTTP and HTTPS)
  - Allow all outbound
- 1 for the internal ALB
  - Allow inbound traffic from Web Tier SG
  - Allow outbound traffic to App Tier SG

Computing (terraform\modules\asg)

- 1 Auto Scaling Group (2 AZ span) for the Web tier
  - "Free-tier friendly" instance specs
  - Amazon Linux
  - Capacity
  - Min 2
  - Desired 2
  - Max 6
  - Scaling Policy with target CPU utilization of 66%
  - User data for containers
- 1 Auto Scaling Group (2 AZ span) for the App Tier
  - "Free-tier friendly" instance specs
  - Amazon Linux
  - Capacity
  - Min 2
  - Desired 2
  - Max 6
  - Scaling Policy with target CPU utilization of 66%
  - User data for containers

IAM (terraform\modules\iam)

- Instance role and instance profile for EC2
- ECR read permissions
- SSM parameter read permissions

ECR (terraform\ecr)

- Frontend repository
- Backend repository
- Lifecycle policy

R53 Type A record (terraform\modules\r53)

- Hosted Zone provided via tfvars: hosted_zone_name

ACM TLS/SSL Certificate (data)

- Provided via tfvars: certificate_domain

SSM Parameters (terraform\modules\ssm)

- backend_image_tag
- frontend_image_tag

## Terraform Folder Structure - Main files

```text
terraform/
├─ ecr/
│  ├─ main.tf
│  ├─ outputs.tf
│  ├─ providers.tf
│  ├─ terraform.tfvars
│  └─ variables.tf
├─ main/
│  ├─ main.tf
│  ├─ output.tf
│  ├─ providers.tf
│  ├─ terraform.tfvars
│  ├─ variables.tf
│  └─ user-data-scripts/
└─ modules/
   ├─ alb/
   ├─ asg/
   ├─ ecr/
   ├─ iam/
   ├─ network/
   ├─ r53/
   ├─ rds/
   ├─ security-group/
   └─ ssm/
```
