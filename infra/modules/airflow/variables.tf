variable "app_name" {

  type = string
}

variable "env" {

  type = string
}

variable "vpc_id" {

  type = string
}

variable "public_subnets" {

  type = list(string)
}

variable "ecs_cluster_id" {

  type = string
}

variable "ecs_cluster_name" {

  type = string
}

variable "ecs_task_execution_role_arn" {

  type = string
}

variable "aws_region" {

  type = string
}

variable "ecr_repository_url" {

  type = string
}

variable "alb_listener_arn" {

  type = string
}

variable "alb_dns_name" {

  type = string
}
variable "alb_security_group_id" {

  type = string
}
variable "db_username" {}

variable "db_password" {

  sensitive = true
}

variable "rds_endpoint" {}
variable "domain_name" {

  type = string
}