# Notes:
# - 8 Subnets:
#   - 2 Public Subnets for NAT Gateways (+ internet-facing ALB)
#   - 2 Private Subnets for the Web Tier (frontend EC2s)
#   - 2 Private Subnets for the App Tier (backend EC2s + internal ALB)
#   - 2 Private Subnets for the Data Tier (RDS)
# - 2 NAT Gateways (one per AZ) for outbound internet from private subnets
# - 3 Route Tables:
#   - 1 Public RT: NAT subnets -> IGW
#   - 2 Private RTs: one per AZ, private subnets -> NAT GW
# - 6 Route Table Associations:
#   - 2 NAT subnets -> public RT (IGW)
#   - 2 Web subnets -> private RT (NAT per AZ)
#   - 2 App subnets -> private RT (NAT per AZ)

# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.module_prefix}-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.module_prefix}-igw"
  }
}

# Availability Zones
data "aws_availability_zones" "available_zones" {}



# ============================================================
# Public Subnets (NAT Gateways + internet-facing ALB)
# ============================================================

resource "aws_subnet" "pub_sub_nat_a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.pub_sub_nat_a_cidr
  availability_zone       = data.aws_availability_zones.available_zones.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.module_prefix}-pub-sub-nat-a"
  }
}

resource "aws_subnet" "pub_sub_nat_b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.pub_sub_nat_b_cidr
  availability_zone       = data.aws_availability_zones.available_zones.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.module_prefix}-pub-sub-nat-b"
  }
}



# ============================================================
# Private Subnets — Web Tier (frontend EC2s)
# ============================================================

resource "aws_subnet" "pri_sub_web_a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.pri_sub_web_a_cidr
  availability_zone       = data.aws_availability_zones.available_zones.names[0]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.module_prefix}-pri-sub-web-a"
  }
}

resource "aws_subnet" "pri_sub_web_b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.pri_sub_web_b_cidr
  availability_zone       = data.aws_availability_zones.available_zones.names[1]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.module_prefix}-pri-sub-web-b"
  }
}



# ============================================================
# Private Subnets — App Tier (backend EC2s + internal ALB)
# ============================================================

resource "aws_subnet" "pri_sub_app_a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.pri_sub_app_a_cidr
  availability_zone       = data.aws_availability_zones.available_zones.names[0]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.module_prefix}-pri-sub-app-a"
  }
}

resource "aws_subnet" "pri_sub_app_b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.pri_sub_app_b_cidr
  availability_zone       = data.aws_availability_zones.available_zones.names[1]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.module_prefix}-pri-sub-app-b"
  }
}



# ============================================================
# Private Subnets — Data Tier (RDS)
# ============================================================

resource "aws_subnet" "pri_sub_data_a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.pri_sub_data_a_cidr
  availability_zone       = data.aws_availability_zones.available_zones.names[0]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.module_prefix}-pri-sub-data-a"
  }
}

resource "aws_subnet" "pri_sub_data_b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.pri_sub_data_b_cidr
  availability_zone       = data.aws_availability_zones.available_zones.names[1]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.module_prefix}-pri-sub-data-b"
  }
}



# ============================================================
# Elastic IPs for NAT Gateways
# ============================================================

resource "aws_eip" "nat_a" {
  domain = "vpc"

  tags = {
    Name = "${var.module_prefix}-nat-eip-a"
  }
}

resource "aws_eip" "nat_b" {
  domain = "vpc"

  tags = {
    Name = "${var.module_prefix}-nat-eip-b"
  }
}



# ============================================================
# NAT Gateways (one per AZ, in public subnets)
# ============================================================

resource "aws_nat_gateway" "nat_a" {
  allocation_id = aws_eip.nat_a.id
  subnet_id     = aws_subnet.pub_sub_nat_a.id

  tags = {
    Name = "${var.module_prefix}-nat-gw-a"
  }

  depends_on = [aws_internet_gateway.internet_gateway]
}

resource "aws_nat_gateway" "nat_b" {
  allocation_id = aws_eip.nat_b.id
  subnet_id     = aws_subnet.pub_sub_nat_b.id

  tags = {
    Name = "${var.module_prefix}-nat-gw-b"
  }

  depends_on = [aws_internet_gateway.internet_gateway]
}



# ============================================================
# Route Tables
# ============================================================

# Public Route Table: NAT subnets -> Internet Gateway
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "${var.module_prefix}-public-rt"
  }
}

# Private Route Table AZ A: private subnets -> NAT Gateway A
resource "aws_route_table" "private_route_table_a" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_a.id
  }

  tags = {
    Name = "${var.module_prefix}-private-rt-a"
  }
}

# Private Route Table AZ B: private subnets -> NAT Gateway B
resource "aws_route_table" "private_route_table_b" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_b.id
  }

  tags = {
    Name = "${var.module_prefix}-private-rt-b"
  }
}



# ============================================================
# Route Table Associations
# ============================================================

# Public subnets (NAT) -> Public Route Table (IGW)
resource "aws_route_table_association" "pub_sub_nat_a_rt_assoc" {
  subnet_id      = aws_subnet.pub_sub_nat_a.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "pub_sub_nat_b_rt_assoc" {
  subnet_id      = aws_subnet.pub_sub_nat_b.id
  route_table_id = aws_route_table.public_route_table.id
}

# Web tier subnets -> Private Route Tables (NAT per AZ)
resource "aws_route_table_association" "pri_sub_web_a_rt_assoc" {
  subnet_id      = aws_subnet.pri_sub_web_a.id
  route_table_id = aws_route_table.private_route_table_a.id
}

resource "aws_route_table_association" "pri_sub_web_b_rt_assoc" {
  subnet_id      = aws_subnet.pri_sub_web_b.id
  route_table_id = aws_route_table.private_route_table_b.id
}

# App tier subnets -> Private Route Tables (NAT per AZ)
resource "aws_route_table_association" "pri_sub_app_a_rt_assoc" {
  subnet_id      = aws_subnet.pri_sub_app_a.id
  route_table_id = aws_route_table.private_route_table_a.id
}

resource "aws_route_table_association" "pri_sub_app_b_rt_assoc" {
  subnet_id      = aws_subnet.pri_sub_app_b.id
  route_table_id = aws_route_table.private_route_table_b.id
}
