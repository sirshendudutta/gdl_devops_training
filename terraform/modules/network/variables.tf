variable "module_prefix" {}
variable "region" {}
variable "vpc_cidr" {}

# Public subnets (NAT Gateways + internet-facing ALB)
variable "pub_sub_nat_a_cidr" {}
variable "pub_sub_nat_b_cidr" {}

# Private subnets — Web Tier (frontend)
variable "pri_sub_web_a_cidr" {}
variable "pri_sub_web_b_cidr" {}

# Private subnets — App Tier (backend)
variable "pri_sub_app_a_cidr" {}
variable "pri_sub_app_b_cidr" {}

# Private subnets — Data Tier (RDS)
variable "pri_sub_data_a_cidr" {}
variable "pri_sub_data_b_cidr" {}