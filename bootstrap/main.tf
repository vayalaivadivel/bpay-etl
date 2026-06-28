resource "aws_route53_zone" "this" {

  name = var.domain_name

  tags = {
    Name    = "${var.app_name}-dns"
    Project = var.app_name
  }
}