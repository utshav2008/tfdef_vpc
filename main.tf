/* ##################################################### VPC ##################################################### */
resource "aws_vpc" "vpc" {
  cidr_block           = "${var.cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags {
    Name                  = "${var.cust_id}-${var.product}-vpc"
    ManagedBy             = "terraform"
    product               = "${var.product}"
    env                   = "${var.environment}"
  }
}


/* ####################################### Subnets ##################################################### */
data "aws_availability_zones" "available" {}


/* ************* Internet gateway for Public Subnet ************ */

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name                  = "${var.product}-igw"
    ManagedBy             = "terraform"
    product               = "${var.product}"
    env                   = "${var.environment}"
  }
}

/* ************** Public Subnets *************** */

resource "aws_subnet" "public" {
  count                   = "${var.subnetcount}"
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${cidrsubnet(aws_vpc.vpc.cidr_block, var.public_subnet_bits, count.index)}"
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"
  map_public_ip_on_launch = true

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name                  = "${var.product}-public-${data.aws_availability_zones.available.names[count.index]}"
    ManagedBy             = "terraform"
    product               = "${var.product}"
    env                   = "${var.environment}"
  }
}

/* **************** NAT gateway for Private Subnet **************** */

resource "aws_nat_gateway" "nat_gw" {
  count         = "${var.enable_nat_gw * var.subnetcount}"
  allocation_id = "${element(aws_eip.nat_eip.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"
  depends_on    = ["aws_internet_gateway.igw"]

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name                  = "${var.cust_id}-${var.product}-vpc"
    ManagedBy             = "terraform"
    product               = "${var.product}"
    env                   = "${var.environment}"
  }
}

/* ***************** EIPs for NAT gateways ****************** */

resource "aws_eip" "nat_eip" {
  count = "${var.enable_nat_gw * var.subnetcount}"
  vpc   = true

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name                  = "${var.cust_id}-${var.product}-vpc"
    ManagedBy             = "terraform"
    product               = "${var.product}"
    env                   = "${var.environment}"
  }
}

/* ******************* Private Subnets ****************** */

resource "aws_subnet" "private" {
  depends_on        = ["aws_nat_gateway.nat_gw"]
  count             = "${var.subnetcount}"
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${cidrsubnet(aws_vpc.vpc.cidr_block, var.private_subnet_bits, count.index +var.subnetcount)}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name                  = "${var.product}-private-${data.aws_availability_zones.available.names[count.index]}"
    ManagedBy             = "terraform"
    product               = "${var.product}"
    env                   = "${var.environment}"
  }
}


/* ############################# Route Tables ########################### */

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name                  = "${var.cust_id}-${var.product}-public"
    ManagedBy             = "terraform"
    product               = "${var.product}"
    env                   = "${var.environment}"
  }
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.vpc.id}"
  count  = "${var.subnetcount}"

  tags {
    Name                  = "${var.cust_id}-${var.product}-private"
    ManagedBy             = "terraform"
    product               = "${var.product}"
    env                   = "${var.environment}"
  }
}

resource "aws_route" "public" {
  depends_on             = ["aws_route_table.public"]
  count                  = "${var.subnetcount}"
  route_table_id         = "${element(aws_route_table.public.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.igw.id}"
}

/* ********************** Route Private Subnets to the NAT GW *************** */

resource "aws_route" "private-nat-gw" {
  depends_on             = ["aws_route_table.private"]
  count                  = "${var.enable_nat_gw * var.subnetcount}"
  route_table_id         = "${element(aws_route_table.private.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(aws_nat_gateway.nat_gw.*.id, count.index)}"
}


/* ********************** Route Associations ******************* */

resource "aws_route_table_association" "public" {
  count          = "${var.subnetcount}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "private" {
  count          = "${var.subnetcount}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}