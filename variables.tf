
variable "name" {}

variable "azs" {
  type = "list"
}

variable "cidr" {}

variable "public_subnet_cidrs" {
  type = "list"
  default = []
}

variable "private_subnet_cidrs" {
  type = "list"
  default = []
}

variable "enable_nat_gateway" {
  default = false
}

variable "single_nat_gateway" {
  description = "Create single NAT gateway if true, otherwise NAT gateway per availability zone. enable_nat_gateway must be true to this take effect."
  default = true
}

variable "enable_dns_support" {
  default = "true"
}

variable "enable_dns_hostnames" {
  default = "true"
}

variable "instance_tenancy" {
  default = "default"
}

variable "enable_s3_endpoint" {
  default = "false"
}

variable "enable_dynamodb_endpoint" {
  default = "false"
}
