data "aws_route53_zone" "solar" {
  name = var.hosted_zone_name
}

resource "aws_route53_record" "a_alias_cf" {
  zone_id = data.aws_route53_zone.solar.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}