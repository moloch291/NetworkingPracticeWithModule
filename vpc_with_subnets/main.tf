# VPC:
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name        = "example-vpc"
    Environment = "${var.env}"
  }
}

# Subnets:
resource "aws_subnet" "subnets" {
  for_each = data.aws_availability_zones.available.names

  depends_on        = [aws_vpc.vpc]
  vpc_id            = aws_vpc.vpc.id
  availability_zone = each.key

  cidr_block = cidrsubnet(
    aws_vpc.vpc.cidr_block,
    8,
    index(
      data.aws_availability_zones.available.names,
      each.key
    ) + 1
  )

  map_public_ip_on_launch = (
    index(data.aws_availability_zones.available.names, each.key) == 2 ? false : true
  )

  tags = {
    Name        = "${
      index(data.aws_availability_zones.available.names, each.key) == 2 ? "private" : "public"
    }-subnet-${
      index(data.aws_availability_zones.available.names, each.key) + 1
    }"

    Subnet      = "${each.key}-${
      index(data.aws_availability_zones.available.names, each.key) + 1
    }"

    Environment = "${var.env}"
  }
}

# Internet gateway:
resource "aws_internet_gateway" "igw" {
    depends_on = [aws_vpc.vpc, aws_subnet.subnets]
    vpc_id     = "${aws_vpc.vpc.id}"

    tags = {
        Name        = "igw"
        Environment = "${var.env}"
    }
}

# Route table to public subnes:
resource "aws_route_table" "public_subnet_rt" {
  vpc_id = "${aws_vpc.vpc.id}"

  depends_on = [aws_vpc.vpc, aws_internet_gateway.igw]

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public_subnet_rt"
  }
}

# Route table association:
resource "aws_route_table_association" "rt_igw_association" {
  depends_on     = [aws_vpc.vpc, aws_subnet.subnets, aws_route_table.public_subnet_rt]
  subnet_id      = aws_subnet.subnets[0].id
  route_table_id = aws_route_table.public_subnet_rt.id
}

# NAT Elastic IP:
resource "aws_eip" "nat_gateway_eip" {
  depends_on = [aws_route_table_association.rt_igw_association]
  vpc = true
}

# NAT gateway:
resource "aws_nat_gateway" "NATgw" {
  depends_on = [aws_internet_gateway.igw, aws_eip.nat_gateway_eip]

  allocation_id = aws_eip.nat_gateway_eip
  subnet_id     = aws_subnet.subnets[0].id

  tags = {
    Name = "NATgw"
  }
}