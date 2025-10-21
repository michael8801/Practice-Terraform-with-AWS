module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 6.0.0"

  domain_name = var.domain_name
  zone_id     = data.aws_route53_zone.solar.zone_id

  region = "us-east-1"

  validation_method = "DNS"

  wait_for_validation = true

  tags = {
    Name = var.domain_name
  }
}