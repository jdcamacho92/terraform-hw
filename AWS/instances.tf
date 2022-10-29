######################################   start     INSTANCES            ########################
##### Instancia
// CREACION DE LA INSTANCIA

resource "aws_instance" "app_server" {
  ami           = var.ami_id
  instance_type = "t2.micro"

#comandos a ejecuttar cuando se lance la instancia, instalar docker, bajar la app, correrla...
  user_data = <<-EOL
  #!/bin/bash -xe

  apt update
  apt install  \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
  wget https://github.com/Nexpeque/cicdworkshop/archive/refs/heads/main.zip
  unzip main.unzip
  cd cicdworkshop-main
  docker built .
  docker run -dt -p 80:80 appinserver
  EOL

#fin de comandos a ejecuttar cuando se lance la instancia,

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
