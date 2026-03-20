#----- Network
data "aws_acm_certificate" "issued" {
  count       = var.enable_r53 ? 1 : 0
  domain      = var.certificate_domain
  statuses    = ["ISSUED"]
  most_recent = true
}

module "route53" {
  count              = var.enable_r53 ? 1 : 0
  source             = "../modules/r53"
  alb_dns_name       = module.web_alb.alb_dns_name
  alb_hosted_zone_id = module.web_alb.alb_hosted_zone_id
  sub_domain         = var.sub_domain
  hosted_zone_name   = var.hosted_zone_name
}

module "network" {
  source             = "../modules/network"
  region             = var.region
  module_prefix      = var.project_name
  vpc_cidr           = var.vpc_cidr
  pub_sub_nat_a_cidr = var.pub_sub_nat_a_cidr
  pub_sub_nat_b_cidr = var.pub_sub_nat_b_cidr
  pri_sub_web_a_cidr = var.pri_sub_web_a_cidr
  pri_sub_web_b_cidr = var.pri_sub_web_b_cidr
  pri_sub_app_a_cidr = var.pri_sub_app_a_cidr
  pri_sub_app_b_cidr = var.pri_sub_app_b_cidr
  pri_sub_data_a_cidr = var.pri_sub_data_a_cidr
  pri_sub_data_b_cidr = var.pri_sub_data_b_cidr
}

module "security-group" {
  source        = "../modules/security-group"
  module_prefix = var.project_name
  vpc_id        = module.network.vpc_id
  allowed_cidrs = var.allowed_cidrs
}

locals {
  ssm_parameter_path_prefix = var.ssm_parameter_path_prefix
  backend_base_url          = "http://${module.internal_alb.alb_dns_name}"
  web_origin                = var.enable_r53 ? "https://${var.sub_domain}.${var.hosted_zone_name}" : "http://${module.web_alb.alb_dns_name}"
  database_url              = "postgresql://${urlencode(var.db_username)}:${urlencode(var.db_password)}@${module.rds.db_endpoint}:${module.rds.db_port}/${module.rds.db_name}"
}

module "iam" {
  source                    = "../modules/iam"
  module_prefix             = var.project_name
  region                    = var.region
  ssm_parameter_path_prefix = local.ssm_parameter_path_prefix
}

#----- Web Tier
module "web_alb" {
  source                         = "../modules/alb"
  module_prefix                  = "${var.project_name}-web"
  alb_sg_id                      = module.security-group.web_alb_sg_id
  sub_a_id                       = module.network.pub_sub_nat_a_id
  sub_b_id                       = module.network.pub_sub_nat_b_id
  vpc_id                         = module.network.vpc_id
  is_internal                    = false
  enable_https                   = var.enable_r53
  enable_http_redirect           = var.enable_r53
  https_listener_certificate_arn = var.enable_r53 ? data.aws_acm_certificate.issued[0].arn : ""
}

module "web_asg" {
  source        = "../modules/asg"
  module_prefix = "${var.project_name}-web"
  region        = var.region
  instance_profile_arn = module.iam.instance_profile_arn
  sg_id         = module.security-group.web_sg_id
  sub_a_id      = module.network.pri_sub_web_a_id
  sub_b_id      = module.network.pri_sub_web_b_id
  tg_arn        = module.web_alb.tg_arn
  user_data     = base64encode(templatefile("${path.module}/user-data-scripts/web-container.sh", {
    region           = var.region
    repo_url         = var.frontend_ecr_repo_url
    ssm_prefix       = local.ssm_parameter_path_prefix
    backend_base_url = local.backend_base_url
  }))
}

#----- App Tier
module "internal_alb" {
  source               = "../modules/alb"
  module_prefix        = "${var.project_name}-internal"
  alb_sg_id            = module.security-group.internal_alb_sg_id
  sub_a_id             = module.network.pri_sub_app_a_id
  sub_b_id             = module.network.pri_sub_app_b_id
  vpc_id               = module.network.vpc_id
  is_internal          = true
  enable_https         = false
  enable_http_redirect = false
}

module "app_asg" {
  source        = "../modules/asg"
  module_prefix = "${var.project_name}-app"
  region        = var.region
  instance_profile_arn = module.iam.instance_profile_arn
  sg_id         = module.security-group.app_sg_id
  sub_a_id      = module.network.pri_sub_app_a_id
  sub_b_id      = module.network.pri_sub_app_b_id
  tg_arn        = module.internal_alb.tg_arn
  user_data     = base64encode(templatefile("${path.module}/user-data-scripts/app-container.sh", {
    region        = var.region
    repo_url      = var.backend_ecr_repo_url
    ssm_prefix    = local.ssm_parameter_path_prefix
    database_url  = local.database_url
    cors_origin   = local.web_origin
  }))
}

#----- Data Tier
module "rds" {
  source            = "../modules/rds"
  module_prefix     = var.project_name
  db_sg_id          = module.security-group.db_sg_id
  pri_sub_data_a_id = module.network.pri_sub_data_a_id
  pri_sub_data_b_id = module.network.pri_sub_data_b_id
  db_username       = var.db_username
  db_password       = var.db_password
  db_name           = var.db_name
}
