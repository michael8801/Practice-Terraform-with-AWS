data "aws_key_pair" "course_tasks" {
  key_name           = "CourseTasks"
  include_public_key = true
}

module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "9.0.0"

  name                             = "asg-${var.instance_name}"
  use_name_prefix                  = false
  vpc_zone_identifier              = module.vpc.private_subnets
  min_size                         = 1 
  max_size                         = 3
  launch_template_name             = "${var.instance_name}-template"
  launch_template_use_name_prefix  = false
  update_default_version           = true
  image_id                         = var.asg_image_id
  instance_type                    = var.asg_instance_type
  key_name                         = data.aws_key_pair.course_tasks.key_name
  security_groups                  = [aws_security_group.web_server_sg_tf.id]
  traffic_source_attachments       = {
    asg-tg = {
        traffic_source_identifier = module.alb.target_groups["asg"].arn
        traffic_source_type       = "elbv2"
    }
  }

  create_iam_instance_profile      = false
  iam_instance_profile_name        = module.ec2_ghostofolio_role.instance_profile_name

   scaling_policies = {
    cpu-policy-greater-than-70 = {
      policy_type               = "TargetTrackingScaling"
      estimated_instance_warmup = 300
      configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ASGAverageCPUUtilization"
        }
        target_value = 70.0
      }
    }
  } 

}