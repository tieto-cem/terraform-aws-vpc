
output "id" {
  value = "${aws_vpc.vpc.id}"
}

output "private_subnet_ids" {
  value = ["${aws_subnet.private_subnet.*.id}"]
}

output "public_subnet_ids" {
  value = ["${aws_subnet.public_subnet.*.id}"]
}

output "nat_gateway_ids" {
  value = ["${aws_nat_gateway.nat_gateway.*.id}"]
}

output "nat_gateway_eips" {
  value = ["${aws_eip.nat_eip.*.public_ip}"]
}