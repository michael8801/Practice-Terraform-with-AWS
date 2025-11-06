module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = var.db_identifier

  engine            = "postgres"
  family            = "postgres17"
  engine_version    = var.db_engine_version
  instance_class    = var.instance_class
  allocated_storage = var.storage_size

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = var.db_port

  vpc_security_group_ids = [aws_security_group.rds_postgres_sg_tf.id]

  create_db_subnet_group = true
  subnet_ids             = module.vpc.private_subnets

  backup_retention_period = 7

  apply_immediately = true
}

output "db_host_address" {
  value = module.db.db_instance_address
}