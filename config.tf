# Configure the AWS Provider
provider "aws" {
  access_key = "${var.secret_id}"
  secret_key = "${var.secret_key}"
  region     = "us-east-1"
}


# Define the VPC
resource "aws_vpc" "lms_review" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true

  tags {
    Name = "lms_vpc"
  }
}

# Define the pubic subnet
resource "aws_subnet" "public-subnet" {
  vpc_id = "${aws_vpc.lms_review.id}"
  cidr_block = "${var.public_subnet_cidr}"
  availability_zone = "us-east-1a"

  tags {
    Name = "Frontend Public Subnet"
  }
}

# Define the private subnet
resource "aws_subnet" "private-subnet" {
  vpc_id = "${aws_vpc.lms_review.id}"
  cidr_block = "${var.private_subnet_cidr}"
  availability_zone = "us-east-1b"

  tags {
    Name = "Backend Private Subnet"
  }
}


# Configure a gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.lms_review.id}"

  tags {
    Name = "VPC Gateway"
  }
}




# Define the route table
resource "aws_route_table" "web-public-rt" {
  vpc_id = "${aws_vpc.lms_review.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags {
    Name = "Public Subnet Route Table"
  }
}


# Assign the route table to the public Subnet
resource "aws_route_table_association" "web-public-rt" {
  subnet_id = "${aws_subnet.public-subnet.id}"
  route_table_id = "${aws_route_table.web-public-rt.id}"
}



resource "aws_security_group" "sg_front" {
  name = "sg_frontend"
  description = "Allow incoming HTTP connections & SSH access"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks =  ["0.0.0.0/0"]
  }

  vpc_id="${aws_vpc.lms_review.id}"

  tags {
    Name = "Front End Security Group"
  }
}



resource "aws_security_group" "sgbackend"{
  name = "sg_backend"
  description = "Allow traffic from public subnet"

  ingress {
    from_port = 5000
    to_port = 5000
    protocol = "tcp"
    cidr_blocks = ["${var.public_subnet_cidr}"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.public_subnet_cidr}"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.public_subnet_cidr}"]
  }

  vpc_id = "${aws_vpc.lms_review.id}"

  tags {
    Name = "Backend Service Group"
  }
}


resource "aws_security_group" "sg_nat_instance" {
  name        = "security_nat"
  description = "Allow ssh only my work network"
  vpc_id      = "${aws_vpc.lms_review.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["41.90.125.50/32"]
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["172.0.0.0/8"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "default" {
  key_name = "terra"
  public_key = "${file("${var.key_path}")}"
}

resource "aws_instance" "backend" {
   ami  = "${var.back_end_ami}"
   instance_type = "t2.micro"
   subnet_id = "${aws_subnet.private-subnet.id}"
   key_name = "${aws_key_pair.default.id}"
   vpc_security_group_ids = ["${aws_security_group.sgbackend.id}"]
   source_dest_check = false

  tags {
    Name = "backend"
  }
}


resource "aws_instance" "frontend" {
   ami  = "${var.front_end_ami}"
   instance_type = "t2.micro"
   subnet_id = "${aws_subnet.public-subnet.id}"
   key_name = "${aws_key_pair.default.id}"
   vpc_security_group_ids = ["${aws_security_group.sg_front.id}"]
   associate_public_ip_address = true
   source_dest_check = false

  tags {
    Name = "frontend"
  }
}


resource "aws_instance" "nat-instance" {
   ami  = "${var.nat_instance_ami}"
   instance_type = "t2.micro"
   subnet_id = "${aws_subnet.public-subnet.id}"
   key_name = "${aws_key_pair.default.id}"
   vpc_security_group_ids = ["${aws_security_group.sg_nat_instance.id}"]
   associate_public_ip_address = true
   source_dest_check = true

  tags {
    Name = "natinstance"
  }
}