provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_vpc" "lab-2" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags { Name = "lab-2-${var.project_name}" }
}

resource "aws_internet_gateway" "lab-2" {
  vpc_id = "${aws_vpc.lab-2.id}"
  tags { Name = "lab-2-${var.project_name}" }
}

resource "aws_subnet" "lab-2" {
  vpc_id = "${aws_vpc.lab-2.id}"
  cidr_block = "10.0.0.0/24"
  tags { Name = "lab-2-${var.project_name}" }

  map_public_ip_on_launch = true
}

resource "aws_route_table" "lab-2" {
  vpc_id = "${aws_vpc.lab-2.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.lab-2.id}"
  }

  tags { Name = "lab-2-${var.project_name}" }
}

resource "aws_route_table_association" "lab-2" {
  subnet_id = "${aws_subnet.lab-2.id}"
  route_table_id = "${aws_route_table.lab-2.id}"
}

resource "aws_security_group" "lab-2" {
  name   = "lab-2-web-${var.project_name}"
  vpc_id = "${aws_vpc.lab-2.id}"

  ingress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
