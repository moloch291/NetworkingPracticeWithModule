resource "aws_vpc" "vpc" {
    cidr_block = var.vpc_cidr

    tags {
        Name        = "${var.vpc_name}-vpc"
        Environment = "${var.env}"
    }
}

resource "aws_subnet" "subnets" {
    for_each = var.subnet_numbers

    depends_on        = [aws_vpc.vpc]
    vpc_id            = aws_vpc.vpc.id
    availability_zone = each.key

    cidr_block = cidrsubnet(aws_vpc.vpc.cidr_block, 8, each.value)

    map_public_ip_on_launch = (each.value == 3 ? false : true)

    tags = {
        Name        = "${each.value == 3 ? "private" : "public"}-subnet-${each.value}"
        Subnet      = "${each.key}-${each.value}"
        Environment = "${var.env}"
    }
}