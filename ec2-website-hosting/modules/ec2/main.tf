resource "aws_instance" "website" {
  ami           = var.ami
  instance_type = var.instance_type

  vpc_security_group_ids      = var.security_groups
  subnet_id                   = var.subnet_id
  associate_public_ip_address = false

  key_name = data.aws_key_pair.course_tasks.key_name

  user_data = var.user_data

  root_block_device {
    volume_size = var.volume_size
  }

  tags = {
    Name = var.instance_name
  }

}

resource "aws_eip" "website" {
  domain = "vpc"
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.website.id
  allocation_id = aws_eip.website.allocation_id
}

data "aws_key_pair" "course_tasks" {
  key_name           = "CourseTasks"
  include_public_key = true

}

output "public_ip" {
  value = aws_eip.website.public_ip
}