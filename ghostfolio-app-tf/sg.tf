resource "aws_security_group" "web_server_sg_tf" {
  name        = "${var.instance_name}-tf"
  description = "Allow HTTP, HTTPS, SSH to web server"
  vpc_id      = module.vpc.vpc_id

/*   ingress {
    description = "HTTPS ingress"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  } */
  ingress {
    description = "HTTP ingress"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [ aws_security_group.alb_sg_tf.id ]
  }
  ingress {
    description = "SSH ingress"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
}

resource "aws_security_group" "elasticache_redis_sg_tf" {
  name        = "${var.cluster_id}-tf"
  description = "Allow 6379 to redis cluster"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "Redis ingress"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.web_server_sg_tf.id]
  }
}

resource "aws_security_group" "rds_postgres_sg_tf" {
  name        = "${var.db_identifier}-tf"
  description = "Allow 5432 to RDS database"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Postgres ingress"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [
      aws_security_group.web_server_sg_tf.id,
      aws_security_group.bastion_host_sg_tf.id
    ]
  }
}

resource "aws_security_group" "bastion_host_sg_tf" {
  name        = "bastion-${var.instance_name}-tf"
  description = "Allow 22 to Bastion"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH allow"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "alb_sg_tf" {
  name        = "alb-${var.instance_name}"
  description = "Allow 80 and 443 to ALB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTPS ingress"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP ingress"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}