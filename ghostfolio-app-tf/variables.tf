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

variable "db_identifier" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_engine_version" {
  type = string
}

variable "db_username" {
  type = string
}

variable "instance_class" {
  type = string
}

variable "db_port" {
  type = number
}

variable "storage_size" {
  type = number
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "bastion_ami" {
  type = string
}

variable "bastion_instance_type" {
  type = string
}

variable "bastion_volume_size" {
  type = number
}

variable "env" {
  type = string
}