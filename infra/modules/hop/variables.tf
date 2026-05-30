variable "env" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "aws_region" {
  type = string
}

variable "ecs_task_execution_role_arn" {
  type = string
}

variable "ecr_repository_url" {
  type = string
}
variable "app_name" {
  type = string
}