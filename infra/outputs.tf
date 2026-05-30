#########################################
# VPC
#########################################

output "vpc_id" {

  value = module.vpc.vpc_id
}

#########################################
# RDS
#########################################

output "rds_endpoint" {

  value = module.rds.rds_endpoint
}

output "db_name" {

  value = var.db_name
}

#########################################
# BASTION
#########################################

output "bastion_public_ip" {

  value = module.ec2.public_ip
}

output "bastion_public_dns" {

  value = module.ec2.public_dns
}

output "bastion_ssh_command" {

  value = "ssh -i ravula-key.pem ubuntu@${module.ec2.public_ip}"
}

#########################################
# SHARED PLATFORM ALB
#########################################

output "alb_dns" {

  value = module.hop.alb_dns
}

output "platform_url" {

  value = "http://${module.hop.alb_dns}"
}

#########################################
# APACHE HOP
#########################################

output "hop_url" {

  value = "http://${module.hop.alb_dns}/hop/status"
}

#########################################
# APACHE AIRFLOW
#########################################

output "airflow_url" {

  value = "http://${module.hop.alb_dns}/airflow"
}

#########################################
# SSH USER
#########################################

variable "ssh_user" {

  default = "ubuntu"
}