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
