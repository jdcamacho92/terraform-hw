######################################   start     INSTANCES            ########################
##### Instancia
// CREACION DE LA INSTANCIA

resource "aws_instance" "app_server" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  //  key_name      = var.ami_key_pair_name

  security_groups             = ["${aws_security_group.allowhttp.id}", "${aws_security_group.allowssh.id}"]
  subnet_id                   = aws_subnet.subnet.id
  associate_public_ip_address = true
  depends_on                  = [aws_internet_gateway.test-env-gw]
  /*
  provisioner "remote-exec" {
    inline = [
      "my commands",
    ]
  }

  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = ""
    #private_key = "${file("~/.ssh/id_rsa")}"
  }*/

  tags = {
    Name = "${var.ami_name}"
  }
}

######################################   END     INSTANCES            ########################
