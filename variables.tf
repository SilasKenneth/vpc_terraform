variable "secret_key" {
  type = "string"
  description = "Contains AWS secret key"
}

variable "secret_id" {
  type = "string"
  description = "Contains the aws secret id"
}

variable "ami_id" {
  type = "string"
  description = "The AWS AMI ID"
}


variable "vpc_cidr" {
  description = "CIDR for the VPC"
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR for the public subnet"
  default = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR for the private subnet"
  default = "10.0.2.0/24"
}

variable "key_path" {
  description = "SSH Public Key path"
  default = "~/.ssh/keys.pub"
}

variable "front_end_ami" {
}

variable "back_end_ami" {
}

variable "nat_instance_ami" {}