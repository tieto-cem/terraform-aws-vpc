
variable "name_prefix" {
  description = "Name prefix used when naming resources"
}

variable "azs" {
  description = "A list of availability zones"
  type = "list"
}

variable "cidr" {
  description = "CIDR block for the VPC"
}

variable "public_subnet_cidrs" {
  description = "A list of CIDR blocks for public subnets. By default, VPC CIDR block is divided and allocated to subnets automatically"
  type = "list"
  default = []
}

variable "private_subnet_cidrs" {
  description = "A list of CIDR blocks for private subnets. By default, VPC CIDR block is divided and allocated to subnets automatically"
  type = "list"
  default = []
}

variable "enable_nat_gateway" {
  description = "Whether NAT Gateway is provisioned or not (Boolean).  single_nat_gateway "
  default = false
}

variable "single_nat_gateway" {
  description = "Whether to create single NAT Gateway or NAT gateway per availability zone. Variable enable_nat_gateway must be true to this take effect."
  default = true
}

variable "enable_dns_support" {
  description = "Whether to enable DNS or not"
  default = "true"
}

variable "enable_dns_hostnames" {
  description = "Whether to enable DNS hostnames or not"
  default = "true"
}

variable "instance_tenancy" {
  description = "Instance tenancy"
  default = "default"
}

variable "enable_s3_endpoint" {
  description = "Whether to enable S3 endpoint or not"
  default = "false"
}

variable "enable_dynamodb_endpoint" {
  description = "Whether to enable DynamoDB endpoint or not"
  default = "false"
}
