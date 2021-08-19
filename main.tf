terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


provider "aws" {
  region = var.region
}


resource "aws_security_group" "ec2_public_security_group" {
  name        = "EC2-aws_security_group"
  description = "Internet reaching access for EC2 Instances"
  vpc_id      = "vpc-f9f79b92"

  ingress {
    from_port   = 8080
    protocol    = "TCP"
    to_port     = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    protocol    = "TCP"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "aws-tiny" {
  instance_type   = var.instance_type
  ami             = data.aws_ami.ubuntu.id
  key_name        = "aws-tiny"
  security_groups = ["${aws_security_group.ec2_public_security_group.name}"]
  tags = {
    Name = "EC2-DEMO-JENKINS",
    LOB  = "${var.lob_dev}"
  }

  volume_tags = {
    "Name" = "EC2-DEMO-JENKINS-volume"
  }
}