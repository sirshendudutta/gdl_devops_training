# Infrastructure Resources (AWS)

## Raw list

- Network
  - VPC
  - Internet Gateway for internet access
  - 2 Availability Zones (HA design)
  - Subnets
    - 2 Public subnets for NAT Gateways (+ internet-facing ALB)
    - 2 Private subnets for the Web Tier (frontend)
    - 2 Private subnets for the App Tier (backend)
    - 2 Private subnets for the RDS Multi-AZ deployment
  - 2 Elastic IPs (one per NAT Gateway)
  - 2 NAT Gateways (one per AZ, in public subnets)
  - Subnet group
  - Route tables
    - 1 Public RT: NAT subnets -> IGW
    - 2 Private RTs: one per AZ, private subnets -> NAT Gateway
  - 6 Route table associations
    - 2 NAT subnets -> public RT (IGW)
    - 2 Web subnets -> private RT (NAT per AZ)
    - 2 App subnets -> private RT (NAT per AZ)
- RDS Multi-AZ (2 AZs) PostgreSQL (18) deployment
- Load Balancing
  - 1 internet-facing ALB in the public NAT subnets (target group)
    - HTTP listener
  - 1 internal ALB in the private App Tier subnets, between the Web Tier (frontend) and the App Tier (backend)
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
- SSM Parameters
- ECR repositories

---

## Detailed list

- Access to the app is through the ALB DNS endpoint
- Public access is HTTP-only
- No HTTPS listener or HTTP-to-HTTPS redirect

Resources

Network (terraform\modules\network)

- VPC
- Internet Gateway for internet access
- 2 Availability Zones (HA design)
- Subnets
  - 2 Public subnets for NAT Gateways (+ internet-facing ALB)
  - 2 Private subnets for the Web Tier (frontend)
  - 2 Private subnets for the App Tier (backend)
  - 2 Private subnets for the RDS Multi-AZ deployment
  - Subnet group
    - RDS receives a group, not a list
    - Includes the 2 Private data subnets
- 2 Elastic IPs (one per NAT Gateway)
- 2 NAT Gateways (one per AZ, in public subnets)
- Route tables
  - 1 Public RT: NAT subnets -> IGW
  - 2 Private RTs: one per AZ, private subnets -> NAT Gateway
- 6 Route table associations
  - 2 NAT subnets -> public RT (IGW)
  - 2 Web subnets -> private RT (NAT per AZ)
  - 2 App subnets -> private RT (NAT per AZ)

RDS (terraform\modules\rds)

- PostgreSQL 18
- Multi-AZ (2 AZs)
- "Free-tier friendly" specs
- Storage scaling enabled
- 20 GB

Load Balancing (terraform\modules\alb)

- 1 internet-facing ALB in the public NAT subnets (target group)
  - HTTP listener
  - No HTTPS listener in this variant
- 1 internal ALB in the private App Tier subnets, between the Web Tier (frontend) and the App Tier (backend)

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
  - Allow inbound internet traffic (HTTP)
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
   ├─ rds/
   ├─ security-group/
   └─ ssm/
```
