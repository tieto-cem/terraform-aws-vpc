[![CircleCI](https://circleci.com/gh/tieto-cem/terraform-aws-vpc.svg?style=shield&circle-token=b87b5b396b1fb627b8c4b2a16cff65d8f153ebfd)](https://circleci.com/gh/tieto-cem/terraform-aws-vpc)

AWS VPC Terraform module
===========================================

Terraform module which creates VPC resources.

Usage
-----

```hcl

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
```

Resource naming
---------------

This module names AWS resources as follows:

| Name                                             | Type                 | Description                                                   |
|--------------------------------------------------|----------------------|---------------------------------------------------------------|
|${var.name_prefix}-vpc                            | VPC                  |                                                               |
|${var.name_prefix}-igw                            | IGW                  |                                                               |
|${var.name_prefix}-public-subnet-${az_name}       | Subnet (public)      |                                                               |     
|${var.name_prefix}-private-subnet-${az_name}      | Subnet (private)     |                                                               |
|${var.name_prefix}-public-route-table             | Route table (public) |                                                               |
|${var.name_prefix}-private-route-table-${az_name} | Route table (private)| multiple tables are created if NAT GW is created per AZ       | 


Example
-------

* [Simple example](https://github.com/tieto-cem/terraform-aws-vpc/tree/master/example/simple)
* [Detailed example](https://github.com/tieto-cem/terraform-aws-vpc/tree/master/example/detailed)