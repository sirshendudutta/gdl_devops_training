output "url" {
  value = "http://${module.web_alb.alb_dns_name}"
}

output "frontend_asg_name" {
  value = module.web_asg.asg_name
}

output "backend_asg_name" {
  value = module.app_asg.asg_name
}
