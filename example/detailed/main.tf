provider "aws" {
  region = "eu-west-1"
}

module "vpc" {
  source                   = "../.."
  name_prefix              = "detailed-example"
  azs                      = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  cidr                     = "10.0.0.0/16"
  public_subnet_cidrs      = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs     = ["10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]
  instance_tenancy         = "default"
  enable_nat_gateway       = true
  single_nat_gateway       = false
  enable_dynamodb_endpoint = true
  enable_s3_endpoint       = true
}