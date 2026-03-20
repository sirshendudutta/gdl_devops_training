output "url" {
  value = var.enable_r53 ? "https://${var.sub_domain}.${var.hosted_zone_name}" : "http://${module.web_alb.alb_dns_name}"
}
