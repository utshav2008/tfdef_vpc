output "id" {
  value = "${aws_vpc.vpc.id}"
}

output "aws_region" {
  value = "${var.aws_region}"
}

output "product" {
  value = "${var.product}"
}

output "environment" {
  value = "${var.environment}"
}

output "cidr" {
  value = "${aws_vpc.vpc.cidr_block}"
}

output "external_subnets" {
  value = "${formatlist("%s", aws_subnet.public.*.id)}"
}

output "internal_subnets" {
  value = "${formatlist("%s", aws_subnet.private.*.id)}"
}

output "availability_zones" {
  value = "${formatlist("%s", aws_subnet.public.*.availability_zone)}"
}

output "nat_eips" {
  value = "${formatlist("%s/32", aws_eip.nat_eip.*.public_ip)}"
}

output "rt_public" {
  value = "${formatlist("%s", aws_route_table.public.*.id)}"
}

output "rt_private" {
  value = "${formatlist("%s", aws_route_table.private.*.id)}"
}

output "cust_id" {
  value = "${var.cust_id}"
}
