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


resource "aws_security_group" "web_security_group" {
  name        = "web_security_group"
  description = "Allow ssh and http/https"
  vpc_id      = aws_vpc.sdn_vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.sdn_vpc.cidr_block]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.sdn_vpc.cidr_block]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.sdn_vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web_security_group"
  }
}

resource "aws_security_group" "app_security_group" {
  name        = "app_security_group"
  description = "Allow traffic from frontend webserver"
  vpc_id      = aws_vpc.sdn_vpc.id

  ingress {
    description = "Accept traffic from web server only"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = [
      aws_security_group.web_security_group.id
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app_security_group"
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

resource "aws_instance" "web_instance" {
  ami                    = "ami-03686c686b463366b"
  instance_type          = "t2.micro"

  subnet_id              = aws_subnet.public_subnet.id
  security_groups = [
    aws_security_group.web_security_group.id
  ]

  tags = {
    Name = "web_server"
  }
}

resource "aws_instance" "application_instance" {
  subnet_id     = aws_subnet.private_subnet.id
  ami           = "ami-03686c686b463366b"
  instance_type = "t2.micro"

  security_groups = [
    aws_security_group.app_security_group.id
  ]

  tags = {
    Name = "application_server"
  }
}
