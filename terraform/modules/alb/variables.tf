variable "module_prefix" {}
variable "alb_sg_id" {}
variable "sub_a_id" {}
variable "sub_b_id" {}
variable "vpc_id" {}
variable "is_internal" {}
variable "enable_https" {
  default = false
}
variable "enable_http_redirect" {
  default = false
}
variable "https_listener_certificate_arn" {
  default = ""
}
variable "https_ssl_policy" {
  default = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}
