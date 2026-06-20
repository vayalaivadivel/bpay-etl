variable "db_name" {}
variable "username" {}
variable "password" {}

variable "private_subnets" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "app_name" {
  type = string
}
variable "env" {

  type = string
}
variable "bastion_security_group_id" {
  description = "Bastion Security Group ID"
  type        = string
}