output "role_arn" {
  value = try(aws_iam_role.github_actions[0].arn, null)
}