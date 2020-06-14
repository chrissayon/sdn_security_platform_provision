variable "region" {
  type = string
  default = "ap-southeast-2"
}

# CIDR block for VPC
variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
}

# CIDR block for public subnet
variable "public_cidr" {
  type = string
  default = "10.0.0.0/24"
}

# CIDR block for private subnet
variable "private_cidr" {
  type = string
  default = "10.0.1.0/24"
}

# Availibility zone for public subnet
variable "public_az" {
  type = string
  default = "ap-southeast-2a"
}

# Availibility zone for private subnet
variable "private_az" {
  type = string
  default = "ap-southeast-2b"
}

# AMI image ID for instance
variable "ami_id" {
  type = string
  default = "ami-03686c686b463366b"
}

variable "instance_type" {
  type = string
  default = "t2.micro"
}