#########################################
# AVAILABILITY ZONES
#########################################

data "aws_availability_zones" "available" {}

#########################################
# VPC
#########################################

resource "aws_vpc" "this" {

  cidr_block = var.vpc_cidr

  tags = {

    Name = "${var.app_name}-vpc-${var.env}"

    Project = var.app_name

    Environment = var.env
  }
}

#########################################
# INTERNET GATEWAY
#########################################

resource "aws_internet_gateway" "igw" {

  vpc_id = aws_vpc.this.id

  tags = {

    Name = "${var.app_name}-igw-${var.env}"

    Project = var.app_name

    Environment = var.env
  }
}

#########################################
# PUBLIC SUBNETS
#########################################

resource "aws_subnet" "public" {

  count = length(var.public_subnets)

  vpc_id = aws_vpc.this.id

  cidr_block = var.public_subnets[count.index]

  availability_zone = data.aws_availability_zones.available.names[count.index]

  map_public_ip_on_launch = true

  tags = {

    Name = "${var.app_name}-pub-${count.index}-${var.env}"

    Project = var.app_name

    Environment = var.env
  }
}

#########################################
# PRIVATE SUBNETS
#########################################

resource "aws_subnet" "private" {

  count = length(var.private_subnets)

  vpc_id = aws_vpc.this.id

  cidr_block = var.private_subnets[count.index]

  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {

    Name = "${var.app_name}-pvt-${count.index}-${var.env}"

    Project = var.app_name

    Environment = var.env
  }
}

#########################################
# ELASTIC IP
#########################################

resource "aws_eip" "nat" {

  domain = "vpc"

  tags = {

    Name = "${var.app_name}-eip-${var.env}"

    Project = var.app_name

    Environment = var.env
  }
}

#########################################
# NAT GATEWAY
#########################################

resource "aws_nat_gateway" "nat" {

  allocation_id = aws_eip.nat.id

  subnet_id = aws_subnet.public[0].id

  tags = {

    Name = "${var.app_name}-nat-${var.env}"

    Project = var.app_name

    Environment = var.env
  }
}

#########################################
# PUBLIC ROUTE TABLE
#########################################

resource "aws_route_table" "public" {

  vpc_id = aws_vpc.this.id

  route {

    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {

    Name = "${var.app_name}-public-rt-${var.env}"

    Project = var.app_name

    Environment = var.env
  }
}

#########################################
# PUBLIC ROUTE TABLE ASSOCIATION
#########################################

resource "aws_route_table_association" "public" {

  count = length(var.public_subnets)

  subnet_id = aws_subnet.public[count.index].id

  route_table_id = aws_route_table.public.id
}

#########################################
# PRIVATE ROUTE TABLE
#########################################

resource "aws_route_table" "private" {

  vpc_id = aws_vpc.this.id

  route {

    cidr_block = "0.0.0.0/0"

    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {

    Name = "${var.app_name}-private-rt-${var.env}"

    Project = var.app_name

    Environment = var.env
  }
}

#########################################
# PRIVATE ROUTE TABLE ASSOCIATION
#########################################

resource "aws_route_table_association" "private" {

  count = length(var.private_subnets)

  subnet_id = aws_subnet.private[count.index].id

  route_table_id = aws_route_table.private.id
}

#########################################
# DEFAULT SECURITY GROUP
#########################################

resource "aws_security_group" "default" {

  name = "${var.app_name}-default-sg-${var.env}"

  vpc_id = aws_vpc.this.id

  #################################
  # INGRESS
  #################################

  ingress {

    from_port = 0

    to_port = 0

    protocol = "-1"

    self = true
  }

  #################################
  # EGRESS
  #################################

  egress {

    from_port = 0

    to_port = 0

    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  #################################
  # TAGS
  #################################

  tags = {

    Name = "${var.app_name}-default-sg-${var.env}"

    Project = var.app_name

    Environment = var.env
  }
}