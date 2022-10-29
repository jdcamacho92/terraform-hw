####firewall
// Security groups
#autorizar trafico http_port

resource "aws_security_group" "allowhttp" {
  name        = "allowhttp"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "http from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #terraform borra el egreso por default, aqui se habilita
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_http"
  }
}


#autorizar trafico SSH nota: solo se puede acceder desde la VPC, no autorizo ninguna IP
resource "aws_security_group" "allowssh" {
  name        = "allowssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "ssh from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    #cidr_blocks = [aws_vpc.vpc.cidr_block]
    cidr_blocks = ["0.0.0.0/0"]

  }
  #terraform borra el egreso por default, aqui se habilita
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}
