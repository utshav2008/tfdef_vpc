Sample Example:

provider "aws" {
}

module "vpc" {
  source                = "git::"
  cust_id               = "dev"
  aws_region            = "us-west-2"
  cidr                  = "10.0.0.0/24"
  environment           = "dev"
  product               = "test-product"
  subnetcount           = "3"
}