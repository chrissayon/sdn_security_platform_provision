provider "aws" {
  profile = "default"
  region  = "ap-southeast-2"
}

resource "aws_instance" "example" {
  ami           = "ami-03686c686b463366b"
  instance_type = "t2.micro"
}