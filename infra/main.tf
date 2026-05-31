module "vpc" {

  source = "./modules/vpc"

  app_name = local.app_name

  env = var.env

  vpc_cidr = var.vpc_cidr

  public_subnets = var.public_subnets

  private_subnets = var.private_subnets
}

############################################################
# RDS
############################################################

module "rds" {

  source = "./modules/rds"

  app_name = local.app_name

  env = var.env

  db_name = local.db_name

  username = var.db_username

  password = var.db_password

  private_subnets = module.vpc.private_subnets

  vpc_id = module.vpc.vpc_id
}

############################################################
# EC2 BASTION
############################################################
module "ec2" {

  source = "./modules/ec2"

  app_name = local.app_name

  env = var.env

  ami = "ami-0f5ee92e2d63afc18"

  public_subnet_id = module.vpc.public_subnets[0]

  vpc_id = module.vpc.vpc_id

  key_name = var.key_name

  ##########################################################
  # IAM
  ##########################################################

  instance_profile_name = module.iam.instance_profile_name

  ##########################################################
  # RDS
  ##########################################################

  rds_endpoint = module.rds.rds_endpoint

  db_username = var.db_username

  db_password = var.db_password

  db_name = local.db_name

  raw_db_name = local.raw_db_name

  replicated_db_name = local.replicated_db_name

  unified_db_name = local.unified_db_name

  ##########################################################
  # SSH
  ##########################################################

  private_key_path = "${path.root}/ravula-key.pem"

  depends_on = [
    module.rds
  ]
}
############################################################
# LAMBDA
############################################################

module "lambda" {

  source = "./modules/lambda"

  app_name = local.app_name

  env = var.env

  lambda_role_arn = module.iam.lambda_role_arn

  hop_url = "http://${module.hop.alb_dns}/hop/runWorkflow"

  hop_username = var.hop_username

  hop_password = var.hop_password
}

############################################################
# EVENTBRIDGE
############################################################

module "eventbridge" {

  source = "./modules/eventbridge"

  app_name = local.app_name

  env = var.env

  lambda_arn = module.lambda.lambda_arn

  lambda_name = module.lambda.lambda_name
}

############################################################
# DMS
############################################################

module "dms" {

  source = "./modules/dms"

  app_name = local.app_name

  env = var.env

  mysql_host = module.rds.rds_endpoint

  mysql_user = var.db_username

  mysql_password = var.db_password

  mysql_database = local.db_name

  raw_db_name = local.raw_db_name

  dms_role_arn = module.iam.dms_role_arn

  dms_vpc_role_dependency = module.iam.dms_vpc_role_ready

  security_group_id = module.ec2.security_group_id

  private_subnets = module.vpc.private_subnets

  vpc_id = module.vpc.vpc_id
}

############################################################
# IAM
############################################################

module "iam" {

  source = "./modules/iam"

  app_name = local.app_name

  env = var.env

  role_name = "${local.app_name}-${var.env}-role"
}

############################################################
# APACHE HOP
############################################################

module "hop" {

  source = "./modules/hop"

  app_name = local.app_name

  ##########################################################
  # ENVIRONMENT
  ##########################################################

  env = var.env

  aws_region = var.aws_region

  ##########################################################
  # NETWORKING
  ##########################################################

  vpc_id = module.vpc.vpc_id

  public_subnets = module.vpc.public_subnets

  private_subnets = module.vpc.private_subnets

  ##########################################################
  # ECS
  ##########################################################

  ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn

  ##########################################################
  # ECR
  ##########################################################

  ecr_repository_url = "986401823783.dkr.ecr.ap-south-1.amazonaws.com/glorytechsystems-platform-images"
}

module "airflow" {

  source = "./modules/airflow"

  app_name = local.app_name

  env = var.env

  vpc_id = module.vpc.vpc_id

  public_subnets = module.vpc.public_subnets

  ecs_cluster_id = module.hop.ecs_cluster_id

  ecs_cluster_name = module.hop.ecs_cluster_name

  ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn

  aws_region = var.aws_region

  ecr_repository_url = "986401823783.dkr.ecr.ap-south-1.amazonaws.com/glorytechsystems-platform-images"

  alb_listener_arn = module.hop.alb_listener_arn

  alb_dns_name = module.hop.alb_dns

  alb_security_group_id = module.hop.alb_sg_id
  db_username           = var.db_username

  db_password = var.db_password

  rds_endpoint = module.rds.rds_endpoint
}


resource "aws_security_group_rule" "rds_from_bastion" {

  type = "ingress"

  from_port = 3306

  to_port = 3306

  protocol = "tcp"

  security_group_id = module.rds.rds_sg_id

  source_security_group_id = module.ec2.security_group_id

  description = "Allow Bastion to connect to MySQL RDS"
}


resource "aws_security_group_rule" "rds_from_dms" {

  type = "ingress"

  from_port = 3306

  to_port = 3306

  protocol = "tcp"

  security_group_id = module.rds.rds_sg_id

  source_security_group_id = module.dms.dms_security_group_id

  description = "Allow DMS to connect to MySQL RDS"
}

resource "aws_security_group_rule" "rds_from_airflow" {

  type = "ingress"

  from_port = 3306

  to_port = 3306

  protocol = "tcp"

  security_group_id = module.rds.rds_sg_id

  source_security_group_id = module.airflow.airflow_security_group_id
}