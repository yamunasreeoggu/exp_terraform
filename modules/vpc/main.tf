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
