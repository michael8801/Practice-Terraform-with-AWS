

module "ec2" {
  source = "./modules/ec2"

  instance_name        = var.instance_name
  instance_type        = var.instance_type
  ami                  = var.ami
  volume_size          = var.volume_size
  user_data = templatefile("${path.module}/user-data.sh.tpl", {
    redis_endpoint = aws_elasticache_replication_group.ghostfolio_redis.primary_endpoint_address
  })
  iam_instance_profile = aws_iam_instance_profile.ec2_backup_profile.name

  subnet_id       = module.vpc.public_subnets[0]
  security_groups = [aws_security_group.web_server_sg_tf.id]
}