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