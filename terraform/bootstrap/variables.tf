variable "region" {}
variable "aws_profile" {}
variable "project_name" {}
variable "frontend_repo_name" {
  default = "frontend"
}
variable "backend_repo_name" {
  default = "backend"
}
variable "lifecycle_keep_last" {
  default = 10
}
variable "frontend_image_tag" {
  default = "latest"
}
variable "backend_image_tag" {
  default = "latest"
}
variable "github_repository" {
  description = "GitHub repository allowed to assume the deployment role, in owner/repo format. Leave empty to skip OIDC resource creation."
  default     = ""
}
variable "github_oidc_branch_ref" {
  description = "Git ref allowed to assume the deployment role."
  default     = "refs/heads/main"
}
variable "deployment_project_name" {
  description = "Project name used by the main Terraform stack for ASG names."
  default     = ""
}
variable "github_actions_role_name" {
  description = "Optional override for the GitHub Actions IAM role name."
  default     = ""
}
