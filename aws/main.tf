provider "aws" {
  region = "us-west-2"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  owners = ["099720109477"]
}

resource "aws_instance" "Node" {
  count                       = 3
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.npb-SG.id]
  associate_public_ip_address = true


  tags = {
    Name = "npb-${count.index + 1}"
  }
}


resource "aws_default_vpc" "default" {}

resource "aws_security_group" "npb-SG" {
  name        = "npbSG"
  description = "Allow ssh & phony ssh"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    description = "Allow all cluster nodes to communicate with each other"
    from_port   = 0   
    to_port     = 0     
    protocol    = "-1"
    self        = true
  }
  ingress {
    description = "NPB port"
    from_port   = 2222
    to_port     = 2222
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

  ingress {
    description = "Ping (ICMP)"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
