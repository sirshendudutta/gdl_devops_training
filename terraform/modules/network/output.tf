output "region" {
  value = var.region
}
output "vpc_id" {
  value = aws_vpc.vpc.id
}

# Public subnets (NAT GWs + internet-facing ALB)
output "pub_sub_nat_a_id" {
  value = aws_subnet.pub_sub_nat_a.id
}
output "pub_sub_nat_b_id" {
  value = aws_subnet.pub_sub_nat_b.id
}

# Private subnets — Web Tier
output "pri_sub_web_a_id" {
  value = aws_subnet.pri_sub_web_a.id
}
output "pri_sub_web_b_id" {
  value = aws_subnet.pri_sub_web_b.id
}

# Private subnets — App Tier
output "pri_sub_app_a_id" {
  value = aws_subnet.pri_sub_app_a.id
}
output "pri_sub_app_b_id" {
  value = aws_subnet.pri_sub_app_b.id
}

# Private subnets — Data Tier
output "pri_sub_data_a_id" {
  value = aws_subnet.pri_sub_data_a.id
}
output "pri_sub_data_b_id" {
  value = aws_subnet.pri_sub_data_b.id
}

output "igw_id" {
  value = aws_internet_gateway.internet_gateway.id
}
