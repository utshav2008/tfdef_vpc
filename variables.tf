variable "subnetcount" {
  description = "Number or public and private subnets each"
  default = "2"
  type = "string"
}

variable "aws_region" {
  description = "AWS Region to host in"
  type        = "string"
}

variable "product" {
  description = "The product to tag these resources with"
  type        = "string"
}

variable "environment" {
  description = "Environment for billing purposes"
  type        = "string"
}

variable "cidr" {
  description = "CIDR for VPC"
  type        = "string"
}


variable "public_subnet_bits" {
  description = "subnet bits to be utilized"
  type        = "string"
  default     = "3"
}

variable "private_subnet_bits" {
  description = "subnet bits to be utilized"
  type        = "string"
  default     = "3"
}

/* NAT GW */
variable "enable_nat_gw" {
  description = "Enable nat gw. 1 is on. 0 is off"
  default     = "1"
}

variable "cust_id" {
  description = "Unique identifier for the VPC"
  type        = "string"
}