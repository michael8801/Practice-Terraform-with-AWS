module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  providers = {
    aws = aws.us_east_1
  }

  domain_name = var.domain_name
  zone_id     = data.aws_route53_zone.solar.zone_id

  validation_method = "DNS"

  wait_for_validation = true

  tags = {
    Name = var.domain_name
  }
}