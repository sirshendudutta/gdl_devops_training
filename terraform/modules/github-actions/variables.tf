variable "region" {}
variable "project_name" {}
variable "deployment_project_name" {
  default = ""
}
variable "github_repository" {
  default = ""
}
variable "github_oidc_branch_ref" {
  default = "refs/heads/main"
}
variable "github_actions_role_name" {
  default = ""
}
variable "frontend_repository_arn" {}
variable "backend_repository_arn" {}
variable "frontend_image_tag_parameter_name" {}
variable "backend_image_tag_parameter_name" {}