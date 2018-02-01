provider "aws" {
  region = "eu-west-1"
}

data "aws_availability_zones" "azs" {}

module "vpc" {
  source      = "github.com/tieto-cem/terraform-aws-vpc?ref=v0.1.1"
  name_prefix = "simple-example"
  cidr        = "10.0.0.0/16"
  azs         = "${data.aws_availability_zones.azs.names}"
}