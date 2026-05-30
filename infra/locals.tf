locals {

  #########################################
  # APP
  #########################################

  app_name = var.app_name

  name_suffix = "${local.app_name}_${var.env}"

  #########################################
  # CORE INFRA
  #########################################

  vpc_name = "${local.app_name}-vpc-${var.env}"

  rds_name = "rl-db-${var.env}"

  iam_role_name = "role_${local.name_suffix}"

  #########################################
  # SOURCE DATABASE
  #########################################

  db_name = var.db_name

  #########################################
  # TARGET DATABASES / SCHEMAS
  #########################################

  raw_db_name = "${var.db_name}_raw_${var.env}"

  replicated_db_name = "${var.db_name}_replicated_${var.env}"

  unified_db_name = "${var.db_name}_unified_${var.env}"

  #########################################
  # COMMON TAGS
  #########################################

  common_tags = {

    Project = local.app_name

    Environment = var.env

    ManagedBy = "Terraform"
  }
}