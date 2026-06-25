moved {
  from = aws_route53_record.airflow
  to   = aws_route53_record.records["airflow"]
}

moved {
  from = aws_route53_record.hop
  to   = aws_route53_record.records["hop"]
}
############################################################
# ROUTE53 HOSTED ZONE
############################################################

resource "aws_route53_zone" "this" {

  name = var.domain_name

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "${var.app_name}-dns-${var.env}"
    Project     = var.app_name
    Environment = var.env
  }
}

resource "aws_route53_record" "records" {

  for_each = var.dns_records

  zone_id = aws_route53_zone.this.zone_id

  name = "${var.env}-${each.value}.${var.domain_name}"

  type = "CNAME"

  ttl = 300

  records = [
    var.alb_dns_name
  ]
}