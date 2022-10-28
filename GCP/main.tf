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

#### CREACION DE LA VM
resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = "f1-micro"
  tags         = ["web", "ssh"]
  ## ASIGNACION DE OS
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.vpc_network.name #crea una dependencia entre la VPC y el VM en el NET.INTF
    access_config {                                         #para asignar una external IP address, no importa que este en blanco
    }
  }
}


#### CREACION DE LA VPC
resource "google_compute_network" "vpc_network" { #crear una VPC
  name                    = "vpc"
  project                 = "deft-advice-366823"
  auto_create_subnetworks = "false"
}



resource "google_compute_subnetwork" "vpc_network" {
  name          = "subnetwork1"
  ip_cidr_range = "10.2.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.vpc_network.id
}



### agregar reglas de firewall

module "firewall_rules" {
  source       = "./firewall-rules"
  project_id   = var.project
  network_name = google_compute_network.vpc_network.id


  rules = [{
    name                    = "allow-http-ingress"
    description             = "allow http access to VM"
    direction               = "INGRESS"
    priority                = null
    ranges                  = ["0.0.0.0/0"]
    source_tags             = null
    source_service_accounts = null
    target_tags             = ["web"]
    target_service_accounts = null
    allow = [{
      protocol = "tcp"
      ports    = ["80"]
    }]
    deny = []
    log_config = {
      metadata = "INCLUDE_ALL_METADATA"
    }
    },
    {
      name                    = "allow-ssh-ingress"
      description             = "allow SSH access to VM"
      direction               = "INGRESS"
      priority                = null
      ranges                  = null
      source_tags             = ["ssh"]
      source_service_accounts = null
      target_tags             = ["ssh"]
      target_service_accounts = null
      allow = [{
        protocol = "tcp"
        ports    = ["22"]
      }]
      deny = []
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
    }

  ]
}
