variable "region" {

  type = string
}

#########################################
# APP
#########################################

variable "app_name" {

  type = string

  default = "bpay-etl"
}

#########################################
# NETWORK
#########################################

variable "vpc_cidr" {

  type = string
}

variable "public_subnets" {

  type = list(string)
}

variable "private_subnets" {

  type = list(string)
}

#########################################
# DATABASE
#########################################

variable "db_username" {

  type = string
}

variable "db_password" {

  type = string

  sensitive = true
}

variable "db_name" {

  type = string
}

#########################################
# EC2
#########################################

variable "key_name" {

  description = "EC2 key pair name"

  type = string
}

#########################################
# APACHE HOP
#########################################

variable "hop_username" {

  type = string
}

variable "hop_password" {

  type = string

  sensitive = true
}

#########################################
# AWS
#########################################

variable "aws_region" {

  type = string
}

variable "env" {
  description = "Deployment environment"
  type        = string
}

variable "domain_name" {
  description = "Base domain name"
  type        = string
  default     = "sakki.in"
}