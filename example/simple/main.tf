provider "aws" {
  region = "eu-west-1"
}

data "aws_availability_zones" "azs" {}

module "vpc" {
  source      = "../../"
  name_prefix = "simple-example"
  cidr        = "10.0.0.0/16"
  azs         = "${data.aws_availability_zones.azs.names}"
}