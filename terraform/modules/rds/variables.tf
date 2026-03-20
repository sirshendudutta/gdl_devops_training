variable "module_prefix" {}
variable "db_sg_id" {}
variable "pri_sub_data_a_id" {}
variable "pri_sub_data_b_id" {}
variable "db_username" {}
variable "db_password" {}
variable "db_name" {
    default = "testdb"
}
variable "max_allocated_storage" {
    default = 100
}
