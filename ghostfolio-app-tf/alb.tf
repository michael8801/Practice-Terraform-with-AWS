module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "5.0.0"

  domain_name       = var.domain_name
  zone_id           = data.aws_route53_zone.solar.zone_id
  validation_method = "DNS"
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "10.0.2"

  name                       = "ghostfolio-alb"
  vpc_id                     = module.vpc.vpc_id
  subnets                    = module.vpc.public_subnets
  security_groups            = [aws_security_group.alb_sg_tf.id]

  target_groups = {
    asg = {
      name              = "${var.instance_name}-tg"
      port              = 80
      protocol          = "HTTP"
      vpc_id            = module.vpc.vpc_id
      create_attachment = false
    }
  }
  listeners = {
    http-https-redirect = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    },
    https = {
      port            = 443
      protocol        = "HTTPS"
      ssl_policy      = "ELBSecurityPolicy-2016-08"
      certificate_arn = module.acm.acm_certificate_arn
      forward = {
        target_group_key = "asg"
      }
    }
  }
}
