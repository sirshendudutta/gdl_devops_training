variable "module_prefix" {}
variable "region" {}
variable "instance_profile_arn" {}
variable "instance_type" {
  default = "t3.micro"
}
variable "user_data" {}
variable "sg_id" {}
variable "max_size" {
  default = 6
}
variable "min_size" {
  default = 2
}
variable "desired_cap" {
  default = 2
}
variable "asg_health_check_type" {
  default = "ELB"
}
variable "sub_a_id" {}
variable "sub_b_id" {}
variable "tg_arn" {}
variable "cpu_target" {
  default = 66
}
