variable "region" {
  type = string
}

variable "ami" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "instance_name" {
  type = string
}

variable "volume_size" {
  type = number
}

variable "domain_name" {
  type = string
}

variable "hosted_zone_name" {
  type = string
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "bucket_name" {

}

variable "cluster_id" {
  type = string
}

variable "es_engine" {
  type = string
}

variable "es_node_type" {
  type = string
}

variable "es_parameter_group_name" {
  type = string
}

variable "redis_engine_version" {
  type = string
}

variable "redis_port" {
  type = number
}

variable "redis_password" {
  type      = string
  sensitive = true
}