variable "ami" {

  description = "AMI ID for EC2"

  type = string
}

variable "public_subnet_id" {

  description = "Public subnet where EC2 will be deployed"

  type = string
}

variable "key_name" {

  description = "EC2 key pair name"

  type = string
}

variable "vpc_id" {

  description = "VPC ID for security group"

  type = string
}

variable "env" {

  description = "Environment (dev/stage/prod)"

  type = string
}

#########################################
# APP
#########################################

variable "app_name" {

  type = string
}

#########################################
# DATABASE
#########################################

variable "rds_endpoint" {

  description = "RDS endpoint"

  type = string
}

variable "db_username" {

  description = "Database username"

  type = string
}

variable "db_password" {

  description = "Database password"

  type = string

  sensitive = true
}

variable "db_name" {

  description = "Database name"

  type = string
}

#########################################
# IAM
#########################################

variable "instance_profile_name" {

  type = string
}

#########################################
# SSH
#########################################

variable "private_key_path" {

  type = string
}


variable "raw_db_name" {
  type = string
}

variable "replicated_db_name" {
  type = string
}

variable "unified_db_name" {
  type = string
}