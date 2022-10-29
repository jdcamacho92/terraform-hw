output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_eip.ip-test-env.public_ip
}

/*
output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.app_server.public_ip
}*/


output "internet_gw" {
  description = "aws_internet_gateway.test-env-gw.id"
  value       = aws_internet_gateway.test-env-gw.id
}

output "routetableid" {
  description = "aws_vpc.vpc.default_route_table_id"
  value       = aws_vpc.vpc.default_route_table_id
}
