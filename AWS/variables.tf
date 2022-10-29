variable "instance_name" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "AppServerInstance"
}


variable "ami_name" {
  default = "ami-0b0ea68c435eb488d"
}
variable "ami_id" {
  default = "ami-0b0ea68c435eb488d"
}
//variable "ami_key_pair_name" {}
