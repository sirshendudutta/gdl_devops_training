variable "module_prefix" {}
variable "vpc_id" {}
variable "allowed_cidrs" {
	description = "List of CIDR blocks allowed to access the internet-facing ALB (e.g. [\"1.2.3.4/32\"])"
	type        = list(string)
	default     = ["0.0.0.0/0"]
}
