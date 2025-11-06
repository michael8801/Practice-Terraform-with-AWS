data "aws_route53_zone" "solar" {
  name = var.hosted_zone_name
}

resource "aws_route53_record" "a_ec2_app_tf" {
  zone_id = data.aws_route53_zone.solar.zone_id
  name    = var.domain_name
  type    = "A"
  ttl     = 300
  records = [module.ec2.public_ip]
}

resource "aws_route53_record" "a_ec2_bastion_tf" {
  zone_id = data.aws_route53_zone.solar.zone_id
  name    = "bastion.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [module.bastion_host[0].public_ip]
}
