terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.70"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "educate"
  region  = "ap-southeast-1"
}

resource "aws_vpc" "myvpc" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = "true"
  tags = {
    Name = "my-test-vpc"
  }
}

resource "aws_vpc_dhcp_options" "dns_resolver" {
  domain_name_servers = ["AmazonProvidedDNS"]
}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id = aws_vpc.myvpc.id
  dhcp_options_id = aws_vpc_dhcp_options.dns_resolver.id
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "192.168.10.0/24"
  availability_zone = "ap-southeast-1b"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "public_subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "192.168.20.0/24"
  availability_zone = "ap-southeast-1a"
  tags = {
    Name = "private_subnet"
  }
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "vpc_gateway"
  }
}

resource "aws_route_table" "route" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }
  tags = {
     Name = "gatewayroute"
  }
}

resource "aws_route_table_association" "public" {
   subnet_id   = aws_subnet.public.id
   route_table_id = aws_route_table.route.id
}

resource "aws_security_group" "my-project-sg" {
  name        = "my-project-sg"
  description = "Allow ssh and httpd inbound traffic"
  vpc_id      = "${aws_vpc.myvpc.id}"
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "172.16.0.0/12", "137.132.0.0/16", "101.78.88.0/24", "203.125.76.0/23", "121.6.0.0/15" ]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    description = "EFS"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "anaconda.org 1"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["104.17.92.24/32"]
  }
  ingress {
    description = "anaconda.org 2"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["104.17.93.24/32"]
  }
  ingress {
    description = "anaconda repo 1"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["104.16.130.3/32"]
  }
  ingress {
    description = "anaconda repo 2"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["104.16.131.3/32"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "my-project-sg"
  }
}

