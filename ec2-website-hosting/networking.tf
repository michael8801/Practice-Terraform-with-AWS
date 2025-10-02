resource "aws_vpc" "app_tf" {

  cidr_block = "10.0.0.0/16"

  tags = {
    Name = var.instance_name
  }
}

resource "aws_internet_gateway" "gw_tf" {
  vpc_id = aws_vpc.app_tf.id

  tags = {
    Name = var.instance_name
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.app_tf.id

  tags = {
    Name = "${var.instance_name}-public-rt"
  }
}

resource "aws_route" "route" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw_tf.id
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "public_subnet_tf" {
  count             = length(data.aws_availability_zones.available.names)
  vpc_id            = aws_vpc.app_tf.id
  cidr_block        = "10.0.${count.index}.0/24"
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "public-subnet-${count.index}-${element(data.aws_availability_zones.available.names, count.index)}"
  }
}

resource "aws_route_table_association" "public_assoc" {
  count          = length(aws_subnet.public_subnet_tf)
  subnet_id      = aws_subnet.public_subnet_tf[count.index].id
  route_table_id = aws_route_table.public.id
}
