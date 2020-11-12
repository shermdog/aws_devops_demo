variable "env_cidr"{
  type = map

  default = {
    "production" = "10.10.10.0/24"
    "development" = "10.20.20.0/24"
  }
}


resource "aws_vpc" "demo" {
  cidr_block       = var.env_cidr[terraform.workspace]
  instance_tenancy = "default"

  tags = {
    name = "rsherman_${terraform.workspace}"
    env = terraform.workspace,
    Creator = "rick.sherman",
    "terraform.managed" = "True"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "demo" {
  count = 2
  vpc_id     = aws_vpc.demo.id
  cidr_block = cidrsubnet(aws_vpc.demo.cidr_block, 1, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    name = "rsherman_${terraform.workspace}_${count.index}"
    env = terraform.workspace,
    Creator = "rick.sherman",
    "terraform.managed" = "True"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.demo.id

  tags = {
    name = "rsherman_${terraform.workspace}"
    env = terraform.workspace,
    Creator = "rick.sherman",
    "terraform.managed" = "True"
  }
}

resource "aws_route_table" "rtb_public" {
  vpc_id = aws_vpc.demo.id
  route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
      name = "rsherman_${terraform.workspace}"
      env = terraform.workspace,
      Creator = "rick.sherman",
      "terraform.managed" = "True"
    }
}

resource "aws_route_table_association" "rtb_public_association" {
  count          = length(aws_subnet.demo)
  subnet_id      = aws_subnet.demo[count.index].id
  route_table_id = aws_route_table.rtb_public.id
}

resource "aws_security_group" "rick" {
  name        = "rsherman_allow_${terraform.workspace}"
  description = "Allow inbound traffic from Rick"
  vpc_id      = aws_vpc.demo.id

  ingress {
    description = "Any from Rick"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.rick_ip}/32"]
  }

  # ingress {
  #   description = "HTTP"
  #   from_port   = 0
  #   to_port     = 80
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name = "rsherman_${terraform.workspace}"
    env = terraform.workspace,
    Creator = "rick.sherman",
    "terraform.managed" = "True"
  }
}

resource "aws_security_group" "alb_to_shop" {
  name        = "rsherman_alb_to_shop_${terraform.workspace}"
  description = "Allow traffic from ALB to shop"
  vpc_id      = aws_vpc.demo.id

  ingress {
    description = "In from ALB SG"
    from_port   = 0
    to_port     = 3000
    protocol    = "tcp"
    security_groups = [aws_security_group.rick.id]
  }

  ingress {
    description = "Any from Rick"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.rick_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name = "rsherman_${terraform.workspace}"
    env = terraform.workspace,
    Creator = "rick.sherman",
    "terraform.managed" = "True"
  }
}
