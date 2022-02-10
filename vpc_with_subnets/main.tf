# VPC:
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name        = "example-vpc"
    Environment = "${var.env}"
  }
}

# Public subnets:
resource "aws_subnet" "public_subnets" {
  count                   = var.public_subnet_count
  depends_on              = [aws_vpc.vpc]
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = data.aws_availability_zones.names[count.index]
  cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index + 1)
  map_public_ip_on_launch = true

  tags = {
    Name        = "public-subnet-${count.index + 1}"
    Subnet      = "${data.aws_availability_zones.names[count.index]}-${count.index + 1}"
    Environment = "${var.env}"
  }
}

# Private subnets:
resource "aws_subnet" "private_subnets" {
  count             = var.private_subnet_count
  depends_on        = [aws_vpc.vpc]
  vpc_id            = aws_vpc.vpc.id
  availability_zone = data.aws_availability_zones.names[count.index]
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index + 1)

  tags = {
    Name        = "private-subnet-${count.index + 1}"
    Subnet      = "${data.aws_availability_zones.names[count.index]}-${count.index + 1}"
    Environment = "${var.env}"
  }
}

# Internet gateway:
resource "aws_internet_gateway" "igw" {
    depends_on = [
      aws_vpc.vpc,
      aws_subnet.private_subnets,
      aws_subnet.public_subnets
    ]

    vpc_id = "${aws_vpc.vpc.id}"

    tags = {
      Name        = "igw"
      Environment = "${var.env}"
    }
}

# Route table to public subnes:
resource "aws_route_table" "public_subnet_rt" {
  vpc_id     = "${aws_vpc.vpc.id}"
  depends_on = [aws_vpc.vpc, aws_internet_gateway.igw]
  tags       = {Name = "public_subnet_rt"}

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# Route table association:
resource "aws_route_table_association" "rt_igw_association" {
  depends_on = [
    aws_vpc.vpc,
    aws_subnet.private_subnets,
    aws_subnet.public_subnets
    aws_route_table.public_subnet_rt
  ]

  subnet_id      = aws_subnet.subnets[0].id
  route_table_id = aws_route_table.public_subnet_rt.id
}

# NAT Elastic IP:
resource "aws_eip" "nat_gateway_eip" {
  depends_on = [aws_route_table_association.rt_igw_association]
  vpc        = true
}

# NAT gateway:
resource "aws_nat_gateway" "NATgw" {
  depends_on    = [aws_internet_gateway.igw, aws_eip.nat_gateway_eip]
  allocation_id = aws_eip.nat_gateway_eip
  subnet_id     = aws_subnet.public_subnets[0].id
  tags          = {Name = "NATgw"}
}


# NAT gateway route table:
resource "aws_route_table" "NATgw_rt" {
  depends_on = [aws_nat_gateway.NATgw]
  vpc_id     = aws_vpc.main.id
  tags       = {Name = "Route Table for NAT Gateway"}

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NATgw.id
  }
}

# Creating an Route Table Association of the NAT Gateway route 
# table with the Private Subnet!
resource "aws_route_table_association" "Nat-Gateway-RT-Association" {
  depends_on     = [aws_route_table.NATgw_rt]
  subnet_id      = aws_subnet.private_subnets.id
  route_table_id = aws_route_table.NATgw_rt.id
}