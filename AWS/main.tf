terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.37"
    }
  }

  required_version = ">= 1.2.0"
}





####GATEWAYS

//gateways creacion

resource "aws_internet_gateway" "test-env-gw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "test-env-gw"
  }
}


##SUBNETS

// creacion de la subnet
resource "aws_subnet" "subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 3, 1)
  availability_zone = "us-east-1a"

  tags = {
    Name = "subnet"
  }
}

//// enrutamiento
resource "aws_route_table" "route-table-test-env" {
  depends_on = [aws_internet_gateway.test-env-gw]
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.test-env-gw.id}"
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.test-env-gw.id
  }
  tags = {
    Name = "test-env-route-table"
  }
}

//asociar tabla de enrutamiento con subred
resource "aws_route_table_association" "subnet-association" {

  subnet_id      = "${aws_subnet.subnet.id}"
  route_table_id = "${aws_route_table.route-table-test-env.id}"
}

//asignar la tabla de enrutamiento como principal de la VPC
resource "aws_main_route_table_association" "a" {
  vpc_id         = aws_vpc.vpc.id
  route_table_id = aws_route_table.route-table-test-env.id
  depends_on = [aws_route_table.route-table-test-env]
}
