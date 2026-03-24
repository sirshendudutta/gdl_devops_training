output "url" {
  value = var.enable_r53 ? "https://${var.sub_domain}.${var.hosted_zone_name}" : "http://${module.web_alb.alb_dns_name}"
}

output "frontend_asg_name" {
  value = module.web_asg.asg_name
}

output "backend_asg_name" {
  value = module.app_asg.asg_name
}
