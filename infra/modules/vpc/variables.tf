variable "vpc_cidr" {

  type = string
}

variable "public_subnets" {

  type = list(string)
}

variable "private_subnets" {

  type = list(string)
}

variable "env" {

  type = string
}

variable "app_name" {

  type = string
}