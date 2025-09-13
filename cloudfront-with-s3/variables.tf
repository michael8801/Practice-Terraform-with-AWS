variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "bucket_name" {
  type        = string
  description = "Globally-unique S3 bucket name"
}

variable "domain_name" {
  type        = string
  description = "FQDN to serve"
}

variable "hosted_zone_name" {
  type = string
}
