module "ec2" {
  source = "./modules/ec2"

  instance_name = var.instance_name
  instance_type = var.instance_type
  ami           = var.ami
  volume_size   = var.volume_size
  user_data     = file("${path.module}/user-data.sh")

  subnet_id       = aws_subnet.public_subnet_tf[0].id
  security_groups = [aws_security_group.web_server_sg_tf.id]
}