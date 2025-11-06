/* resource "aws_elasticache_replication_group" "ghostfolio_redis" {
  replication_group_id = var.cluster_id
  description          = "Ghostfolio Redis cluster"

  engine               = var.es_engine
  node_type            = var.es_node_type
  parameter_group_name = var.es_parameter_group_name
  engine_version       = var.redis_engine_version
  port                 = var.redis_port

  num_node_groups         = 1
  replicas_per_node_group = 0


  subnet_group_name  = aws_elasticache_subnet_group.ghostfolio_redis.name
  security_group_ids = [aws_security_group.elasticache_redis_sg_tf.id]
  transit_encryption_enabled = false
  automatic_failover_enabled = false
  apply_immediately          = true

}

resource "aws_elasticache_subnet_group" "ghostfolio_redis" {
  name       = "${var.cluster_id}-private"
  subnet_ids = module.vpc.private_subnets
}

output "redis_endpoint" {
  value = aws_elasticache_replication_group.ghostfolio_redis.primary_endpoint_address
  description = "Address of a primary node in Redis cluster"
}
 */