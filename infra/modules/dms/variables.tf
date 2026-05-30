variable "mysql_host" {}
variable "mysql_user" {}
variable "mysql_password" {}
variable "mysql_database" {}
variable "raw_db_name" {}
variable "dms_role_arn" {}
variable "env" {}
variable "dms_vpc_role_dependency" {}
variable "private_subnets" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}
variable "vpc_id" {

  type = string
}
variable "app_name" {
  type = string
}