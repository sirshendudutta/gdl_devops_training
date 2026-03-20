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
