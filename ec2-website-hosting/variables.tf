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
  type        = string
}

variable "hosted_zone_name" {
  type = string
}
