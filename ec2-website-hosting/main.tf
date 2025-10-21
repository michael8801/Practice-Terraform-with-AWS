module "ec2" {
  source = "./modules/ec2"

  instance_name = var.instance_name
  instance_type = var.instance_type
  ami           = var.ami
  volume_size   = var.volume_size
  user_data     = file("${path.module}/user-data.sh")
  iam_instance_profile = aws_iam_instance_profile.ec2_backup_profile.name

  subnet_id       = module.vpc.public_subnets[0]
  security_groups = [aws_security_group.web_server_sg_tf.id]
}