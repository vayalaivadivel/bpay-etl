locals {

  app_name = var.app_name

  name_suffix = "${local.app_name}_${var.env}"

  db_name = var.db_name

  raw_db_name = "${var.db_name}_raw_${var.env}"

  replicated_db_name = "${var.db_name}_replicated_${var.env}"

  unified_db_name = "${var.db_name}_unified_${var.env}"

  common_tags = {

    Project = local.app_name

    Environment = var.env

    ManagedBy = "Terraform"
  }
}