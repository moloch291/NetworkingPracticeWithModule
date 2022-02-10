resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name        = "example-vpc"
    Environment = "${var.env}"
  }
}

resource "aws_subnet" "subnets" {
  for_each = data.aws_availability_zones.available.names

  depends_on        = [aws_vpc.vpc]
  vpc_id            = aws_vpc.vpc.id
  availability_zone = each.key

  cidr_block = cidrsubnet(
    aws_vpc.vpc.cidr_block, 8, index(data.aws_availability_zones.available.names, each.key) + 1
  )

  map_public_ip_on_launch = (each.value == 3 ? false : true)

  tags = {
    Name        = "${each.value == 3 ? "private" : "public"}-subnet-${each.value}"
    Subnet      = "${each.key}-${each.value}"
    Environment = "${var.env}"
  }
}