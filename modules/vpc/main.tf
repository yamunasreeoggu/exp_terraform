resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.env}-vpc"
  }
}

resource "aws_subnet" "public_subnets" {
  count = length(var.public_subnets) # as we have list of two values for public subnets, we need to declare them using count loop for iteration
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.public_subnets[count.index] # count.index is needed for iteration as i/p has list of two values for public subnets
  availability_zone = var.azs[count.index]

  tags = {
    Name = "public-subnet-${count.index+1}"
  }
}

resource "aws_subnet" "private_subnets" {
  count = length(var.private_subnets)
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.private_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name = "private-subnet-${count.index+1}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.env}-igw"
  }
}

resource "aws_eip" "eip" {
  domain   = "vpc"
  tags = {
    Name = "${var.env}-eip"
  }
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public_subnets[0].id

  tags = {
    Name = "${var.env}-ngw"
  }
}

resource "aws_vpc_peering_connection" "peering" {
  peer_owner_id = var.account_id
  peer_vpc_id   = var.default_vpc_id
  vpc_id        = aws_vpc.vpc.id
  auto_accept   = true

  tags = {
    Name = "peering_connection_from_default-VPC_to_${var.env}-VPC"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }

  route {
    cidr_block = var.default_vpc_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
  }

  tags = {
    Name = "private-route-table"
  }
}