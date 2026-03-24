output "frontend_repository_url" {
  value = module.ecr.frontend_repository_url
}

output "backend_repository_url" {
  value = module.ecr.backend_repository_url
}

output "frontend_repository_arn" {
  value = module.ecr.frontend_repository_arn
}

output "backend_repository_arn" {
  value = module.ecr.backend_repository_arn
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

output "github_actions_role_arn" {
  value = module.github_actions.role_arn
}
