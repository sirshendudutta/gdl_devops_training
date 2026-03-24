output "frontend_image_tag_name" {
  value = aws_ssm_parameter.frontend_image_tag.name
}

output "backend_image_tag_name" {
  value = aws_ssm_parameter.backend_image_tag.name
}

output "parameter_path_prefix" {
  value = var.path_prefix
}
