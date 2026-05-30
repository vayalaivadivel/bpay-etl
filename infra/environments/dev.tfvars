env = "dev"

app_name = "bpay-etl"

region = "ap-south-1"

aws_region = "ap-south-1"

#########################################
# NETWORK
#########################################

vpc_cidr = "10.0.0.0/16"

public_subnets = [
  "10.0.1.0/24",
  "10.0.2.0/24"
]

private_subnets = [
  "10.0.10.0/24",
  "10.0.20.0/24"
]

#########################################
# DATABASE
#########################################

db_username = "ravula"

db_password = "password"

db_name = "rldb"

#########################################
# EC2
#########################################

key_name = "ravula-key"

#########################################
# APACHE HOP
#########################################

hop_username = "ravula"

hop_password = "password"