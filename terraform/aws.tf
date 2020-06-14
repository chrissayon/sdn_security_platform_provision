provider "aws" {
  profile = "default"
  region  = "ap-southeast-2"
}

# Creating VPC related resources
resource "aws_vpc" "sdn_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "sdnVPC"
  }
}

# Create internet gateway
resource "aws_internet_gateway" "sdn_internet_gateway" {
  vpc_id = aws_vpc.sdn_vpc.id

  tags = {
    Name = "sdn_internet_gateway"
  }
}

# Create public routing table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.sdn_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sdn_internet_gateway.id
  }

  tags = {
    Name = "public_route_table"
  }
}



# Create security groups
resource "aws_security_group" "web_security_group" {
  name        = "web_security_group"
  description = "Allow ssh and http/https"
  vpc_id      = aws_vpc.sdn_vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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
  map_public_ip_on_launch = true

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


resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}



resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


resource "aws_key_pair" "generated_key" {
  key_name   = "SDN Key Pair"
  public_key = tls_private_key.key.public_key_openssh
}

resource "local_file" "output_key_file" {
  content = tls_private_key.key.private_key_pem
  filename = "web_server_key.pem"
}



resource "aws_instance" "web_instance" {
  ami                    = "ami-03686c686b463366b"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.generated_key.key_name

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
