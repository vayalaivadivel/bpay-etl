resource "aws_route53_zone" "this" {

  name = var.domain_name

  tags = {
    Name        = "${var.app_name}-dns-${var.env}"
    Project     = var.app_name
    Environment = var.env
  }
}

resource "aws_route53_record" "airflow" {

  zone_id = aws_route53_zone.this.zone_id

  name = "${var.env}-airflow.${var.domain_name}"

  type = "CNAME"

  ttl = 300

  records = [
    var.alb_dns_name
  ]
}

resource "aws_route53_record" "hop" {

  zone_id = aws_route53_zone.this.zone_id

  name = "${var.env}-hop.${var.domain_name}"

  type = "CNAME"

  ttl = 300

  records = [
    var.alb_dns_name
  ]
}