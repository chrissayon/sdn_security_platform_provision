provider "aws" {
  profile = "default"
  region  = "ap-southeast-2"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "sdnVPC"
  }
}

resource "aws_instance" "webEC2" {
  ami           = "ami-03686c686b463366b"
  instance_type = "t2.micro"

  tags = {
    Name = "webserver"
  }
}

