variable "ami" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "instance_name" {
  type = string
}

variable "user_data" {
  type = string
}

variable "security_groups" {
  type = list(string)
}

variable "subnet_id" {
  type = string
}

variable "volume_size" {
  type = number
}

variable "iam_instance_profile" {
  type    = string
  default = null
}

variable "enable_eip" {
  type    = bool
  default = true
}

