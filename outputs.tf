
output "id" {
  description = "VPC id"
  value = aws_vpc.vpc.id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value = aws_subnet.private_subnet.*.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value = aws_subnet.public_subnet.*.id
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value = aws_nat_gateway.nat_gateway.*.id
}

output "nat_gateway_public_ips" {
  description = "List of NAT Gateway public IP addresses"
  value = aws_eip.nat_eip.*.public_ip
}