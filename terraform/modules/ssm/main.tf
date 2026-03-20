locals {
  normalized_prefix = trim(var.path_prefix, "/")
  base_path         = local.normalized_prefix == "" ? "" : "/${local.normalized_prefix}"
}

resource "aws_ssm_parameter" "frontend_image_tag" {
  name        = "${local.base_path}/frontend/image_tag"
  description = "Frontend container image tag"
  type        = "String"
  value       = var.frontend_image_tag
  overwrite   = true

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "backend_image_tag" {
  name        = "${local.base_path}/backend/image_tag"
  description = "Backend container image tag"
  type        = "String"
  value       = var.backend_image_tag
  overwrite   = true

  lifecycle {
    ignore_changes = [value]
  }
}
