module "ec2" {
  source = "./modules/ec2"

  instance_name = var.instance_name
  instance_type = var.instance_type
  ami           = var.ami
  volume_size   = var.volume_size
  user_data = templatefile("${path.module}/user-data.sh.tpl", {
    redis_endpoint  = "null"
    db_name         = var.db_name
    db_user         = var.db_username
    db_password     = var.db_password
    db_host_address = module.db.db_instance_address
  })
  iam_instance_profile = module.ec2_ghostofolio_role.instance_profile_name

  subnet_id       = module.vpc.public_subnets[0]
  security_groups = [aws_security_group.web_server_sg_tf.id]
}

module "bastion_host" {
  source = "./modules/ec2"
  count  = var.env == "dev" ? 1 : 0

  instance_name = "bastion-${var.instance_name}"
  instance_type = var.bastion_instance_type
  ami           = var.bastion_ami
  volume_size   = var.bastion_volume_size
  user_data     = file("${path.module}/bastion-user-data.sh")

  subnet_id       = module.vpc.public_subnets[0]
  security_groups = [aws_security_group.bastion_host_sg_tf.id]

}