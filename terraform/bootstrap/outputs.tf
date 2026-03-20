output "frontend_repository_url" {
  value = module.ecr.frontend_repository_url
}

output "backend_repository_url" {
  value = module.ecr.backend_repository_url
}

output "frontend_ssm_parameter" {
  value = "/${var.project_name}/frontend/image_tag"
}

output "backend_ssm_parameter" {
  value = "/${var.project_name}/backend/image_tag"
}

output "ssm_parameter_prefix" {
  value = "/${var.project_name}"
}
