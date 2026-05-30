resource "aws_ecr_repository" "this" {

  name = var.repo_name

  image_scanning_configuration {

    scan_on_push = true
  }

  ##################################################
  # PREVENT ECR DELETE
  ##################################################

  lifecycle {

    prevent_destroy = true
  }
}