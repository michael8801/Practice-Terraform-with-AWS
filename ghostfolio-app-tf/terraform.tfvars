region = "eu-central-1"

# EC2
ami           = "ami-0a116fa7c861dd5f9"
instance_type = "t3.medium"
instance_name = "app-tf"
volume_size   = 15

# Route53
hosted_zone_name = "solar.pp.ua."
domain_name      = "solar.pp.ua"

# S3
bucket_name = "pg-dumps-from-ec2-pg-tf"


# Elasticache
cluster_id              = "ghostfolio-cluster"
es_engine               = "redis"
es_node_type            = "cache.t3.micro"
es_parameter_group_name = "default.redis7"
redis_engine_version    = "7.1"
redis_port              = 6379
