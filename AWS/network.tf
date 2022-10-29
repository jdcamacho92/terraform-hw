######################################   start     NETWORK             ########################
##### VPC
// CREACION DE LA VPC

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "vpc"
  }
}

##### Asignacion IP
//asignacion IP elastic_ip

resource "aws_eip" "ip-test-env" {
  instance = aws_instance.app_server.id
  vpc      = true
}
######################################     END   NETWORK             ########################
