variable "region" {}
variable "aws_profile" {}
variable "project_name" {}

variable "vpc_cidr" {
  # 10.0.0.0 - 10.0.255.255 (65536 IPs)
  default = "10.0.0.0/16"
}

# Public subnets (NAT Gateways + internet-facing ALB)
variable "pub_sub_nat_a_cidr" {
  default = "10.0.1.0/24"
}
variable "pub_sub_nat_b_cidr" {
  default = "10.0.2.0/24"
}

# Private subnets — Web Tier (frontend)
variable "pri_sub_web_a_cidr" {
  default = "10.0.3.0/24"
}
variable "pri_sub_web_b_cidr" {
  default = "10.0.4.0/24"
}

# Private subnets — App Tier (backend)
variable "pri_sub_app_a_cidr" {
  default = "10.0.5.0/24"
}
variable "pri_sub_app_b_cidr" {
  default = "10.0.6.0/24"
}

# Private subnets — Data Tier (RDS)
variable "pri_sub_data_a_cidr" {
  default = "10.0.7.0/24"
}
variable "pri_sub_data_b_cidr" {
  default = "10.0.8.0/24"
}

variable "db_name" {
  default = "ThreeTierDemoDB"
}
variable "db_username" {
  default = "appuser"
}
variable "db_password" {
  default = "password"
}
variable "frontend_ecr_repo_url" {}
variable "backend_ecr_repo_url" {}
variable "ssm_parameter_path_prefix" {}

variable "allowed_cidrs" {
  description = "List of CIDR blocks allowed to access the internet-facing ALB. Set to [\"x.x.x.x/32\"] to restrict to a single IP."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
