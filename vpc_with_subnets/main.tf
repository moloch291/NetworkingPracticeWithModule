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
    Subnet      = "${each.key}-${each.value}"
    Environment = "${var.env}"
  }
}