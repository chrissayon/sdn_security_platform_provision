provider "aws" {
  profile = "default"
  region  = var.region
}

# Creating VPC related resources
resource "aws_vpc" "sdn_vpc" {
  cidr_block = var.vpc_cidr

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

# Create private routing table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.sdn_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sdn_internet_gateway.id
  }

  tags = {
    Name = "private_route_table"
  }
}



# Create frontend security group
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
    ipv6_cidr_blocks = ["::/0"]
    
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "web_security_group"
  }
}


# Create backend security group
resource "aws_security_group" "app_security_group" {
  name        = "app_security_group"
  description = "Allow traffic from frontend webserver and ssh"
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

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "app_security_group"
  }
}

# Create public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.sdn_vpc.id
  cidr_block        = var.public_cidr
  availability_zone = var.public_az
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet1"
  }
}

# Create private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.sdn_vpc.id
  cidr_block        = var.private_cidr
  availability_zone = var.private_az

  tags = {
    Name = "private_subnet1"
  }
}

# Associate public route table to public subnet
resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Associate public route table to public subnet
resource "aws_route_table_association" "private_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}


# SSH key generation
resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


resource "aws_key_pair" "generated_key" {
  key_name   = "SDN Key Pair"
  public_key = tls_private_key.key.public_key_openssh
}

# Output SSH key to local file 'web_server_key.pem'
resource "local_file" "output_key_file" {
  content = tls_private_key.key.private_key_pem
  filename = "web_server_key.pem"
  file_permission = "0400"
}


# Create web instance (frontend)
resource "aws_instance" "web_instance" {
  ami                    = var.ami_id
  subnet_id              = aws_subnet.public_subnet.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.generated_key.key_name

  
  security_groups = [
    aws_security_group.web_security_group.id
  ]

  tags = {
    Name = "web_server"
  }
}

# Create app instance (backend)
resource "aws_instance" "app_instance" {
  ami           = var.ami_id
  subnet_id     = aws_subnet.private_subnet.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.generated_key.key_name

  associate_public_ip_address = true
  security_groups = [
    aws_security_group.app_security_group.id
  ]

  tags = {
    Name = "application_server"
  }
}
