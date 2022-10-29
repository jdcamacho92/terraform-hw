/*
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "3.22.0"
    }
  }
}
*/
#la linea de bloque anterior no se necesita si se ejecuta terraform init desde chip m1

####### DEFINICION DE CLOUD ######
provider "google" {
  #credentials = file("deft-advice-366823-ca31b7bc45ea.json") #para autenticar hardcoded
  credentials = file(var.credentials_file)

  project = "deft-advice-366823"
  region  = "us-central1"
  zone    = "us-central1-c"
}


########## creacion del RSA keypair para el acceso ssh usando hashicorp/tls.
## se anade a outputs para tener la private key con
## terraform output -json | jq -r ".ssh_private_key.value" > .ssh/google_compute_engine

provider "tls" {
  // no config needed
}
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "ssh_private_key_pem" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = ".ssh/google_compute_engine"
  file_permission = "0600"
}


####################################################

#### CREACION DE LA VPC
resource "google_compute_network" "vpc_network" { #crear una VPC
  name                    = "vpc"
  project                 = "deft-advice-366823"
  //auto_create_subnetworks = "false"
}

#### PARA OBTENER  IP estatica y natearla en la configuracion de la VM
resource "google_compute_address" "static_ip" {
  name = "debian-vm"
}

##HABILITAR ACCESO SSH
resource "google_compute_firewall" "allow_ssh" {
  name          = "allow-ssh"
  network       = google_compute_network.vpc_network.name
  target_tags   = ["allow-ssh"]
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

####HABILITAR ACCESO HTTP
resource "google_compute_firewall" "allow_http" {
  name          = "allow-http"
  network       = google_compute_network.vpc_network.name
  target_tags   = ["allow-http"]
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}

#OBTENER USUARIO
data "google_client_openid_userinfo" "me" {}



//////////////////////////
#### CREACION DE LA VM
resource "google_compute_instance" "debian_vm" {
  name         = "debian"
  machine_type = "f1-micro"
  tags         = ["allow-ssh"] // this receives the firewall rule

  metadata = {
    ssh-keys = "${split("@", data.google_client_openid_userinfo.me.email)[0]}:${tls_private_key.ssh.public_key_openssh}"
  }

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name

    access_config {
      nat_ip = google_compute_address.static_ip.address
    }
  }
}
