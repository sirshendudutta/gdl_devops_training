module "ecr" {
  source              = "../modules/ecr"
  project_name        = var.project_name
  frontend_repo_name  = var.frontend_repo_name
  backend_repo_name   = var.backend_repo_name
  lifecycle_keep_last = var.lifecycle_keep_last
}

module "ssm" {
  source             = "../modules/ssm"
  path_prefix        = "/${var.project_name}"
  frontend_image_tag = var.frontend_image_tag
  backend_image_tag  = var.backend_image_tag
}

module "github_actions" {
  source = "../modules/github-actions"

  region                            = var.region
  project_name                      = var.project_name
  deployment_project_name           = var.deployment_project_name
  github_repository                 = var.github_repository
  github_oidc_branch_ref            = var.github_oidc_branch_ref
  github_actions_role_name          = var.github_actions_role_name
  frontend_repository_arn           = module.ecr.frontend_repository_arn
  backend_repository_arn            = module.ecr.backend_repository_arn
  frontend_image_tag_parameter_name = module.ssm.frontend_image_tag_name
  backend_image_tag_parameter_name  = module.ssm.backend_image_tag_name
}