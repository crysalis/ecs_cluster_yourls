resource "aws_vpc" "default" {
  provider             = "aws.main"
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true

  tags {
    Name = "Yourls VPC"
  }
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name        = "yourls-igw"
  }
}

resource "aws_eip" "nat_eip_1" {
  vpc        = true
  depends_on = ["aws_internet_gateway.gateway"]
}

resource "aws_eip" "nat_eip_2" {
  vpc        = true
  depends_on = ["aws_internet_gateway.gateway"]
}

resource "aws_nat_gateway" "nat_1" {
  allocation_id = "${aws_eip.nat_eip_1.id}"
  subnet_id     = "${aws_subnet.public_subnet_1.id}"
  depends_on    = ["aws_internet_gateway.gateway"]
}

resource "aws_nat_gateway" "nat_2" {
  allocation_id = "${aws_eip.nat_eip_2.id}"
  subnet_id     = "${aws_subnet.public_subnet_2.id}"
  depends_on    = ["aws_internet_gateway.gateway"]
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags {
    Name        = "Public subnet 1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags {
    Name        = "Public subnet 2"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags {
    Name        = "Private subnet"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false

  tags {
    Name        = "Private subnet"
  }
}
resource "aws_route_table" "private_1" {
  vpc_id = "${aws_vpc.default.id}"
}

resource "aws_route_table" "private_2" {
  vpc_id = "${aws_vpc.default.id}"
}

resource "aws_route_table" "public_1" {
  vpc_id = "${aws_vpc.default.id}"
}

resource "aws_route_table" "public_2" {
  vpc_id = "${aws_vpc.default.id}"
}

resource "aws_route" "public_internet_gateway_1" {
  route_table_id         = "${aws_route_table.public_1.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.gateway.id}"
}

resource "aws_route" "public_internet_gateway_2" {
  route_table_id         = "${aws_route_table.public_2.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.gateway.id}"
}

resource "aws_route" "private_nat_gateway_1" {
  route_table_id         = "${aws_route_table.private_1.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.nat_1.id}"
}

resource "aws_route" "private_nat_gateway_2" {
  route_table_id         = "${aws_route_table.private_2.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.nat_2.id}"
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = "${aws_subnet.public_subnet_1.id}"
  route_table_id = "${aws_route_table.public_1.id}"
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = "${aws_subnet.public_subnet_2.id}"
  route_table_id = "${aws_route_table.public_2.id}"
}

resource "aws_route_table_association" "private_1" {
  subnet_id       = "${aws_subnet.private_subnet_1.id}"
  route_table_id  = "${aws_route_table.private_1.id}"
}

resource "aws_route_table_association" "private_2" {
  subnet_id       = "${aws_subnet.private_subnet_2.id}"
  route_table_id  = "${aws_route_table.private_2.id}"
}

resource "aws_security_group" "default" {
  name        = "default-vpc-sg"
  vpc_id      = "${aws_vpc.default.id}"
  depends_on  = ["aws_vpc.default"]

  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = "true"
  }
}
