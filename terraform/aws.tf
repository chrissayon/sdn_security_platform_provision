provider "aws" {
  profile = "default"
  region  = "ap-southeast-2"
}

resource "aws_vpc" "sdn_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "sdnVPC"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.sdn_vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "ap-southeast-2a"

  tags = {
    Name = "public_subnet1"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.sdn_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-southeast-2b"

  tags = {
    Name = "private_subnet1"
  }
}

resource "aws_instance" "webEC2" {
  ami           = "ami-03686c686b463366b"
  instance_type = "t2.micro"

  tags = {
    Name = "webserver"
  }
}

