resource "aws_vpc" "vpc" {
  cidr_block = "10.1.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.env}-vpc"
  }
}

resource "aws_subnet" "subnets" {
  count = length(local.az_names)*2
  vpc_id = aws_vpc.vpc.id
  map_public_ip_on_launch = count.index < length(local.az_names) ? true : false
  cidr_block = "10.1.${count.index}.0/24"
  availability_zone_id = count.index < length(local.az_names) ? local.az_names[count.index] : local.az_names[count.index - length(local.az_names)]
  tags = {
    Name = count.index < length(local.az_names) ? "${var.env}-public-subnet${count.index}" : "${var.env}-private-subnet${count.index}"
    "kubernetes.io/role/elb" = count.index < length(local.az_names) ? "1" : ""
    "kubernetes.io/role/internal-elb" = count.index >= length(local.az_names) ? "1" : ""
  }
}

#Creating a first route table for public subnets
resource "aws_default_route_table" "main" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id
  tags = {
    Name = "${var.env}-mainroutetable"
  }
}

resource "aws_route_table_association" "public_subnets" {
  count = length(local.az_names)
  #subnet_id = aws_subnet.subnets[count.index].id
  subnet_id = slice(aws_subnet.subnets, 0, length(local.az_names))[count.index].id
  route_table_id = aws_default_route_table.main.id
}

#Creating a second route table for private subnets
resource "aws_route_table" "custom" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.env}-customroutetable"
  }
}

resource "aws_route_table_association" "private_subnets" {
  count = length(local.az_names)
  #subnet_id = aws_subnet.subnets[count.index+length(local.az_names)].id
  subnet_id = slice(aws_subnet.subnets, length(local.az_names), length(local.az_names)*2)[count.index].id
  route_table_id = aws_route_table.custom.id
}

resource "aws_internet_gateway" "vpc_igw"{
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.env}-internetgateway"
  }
}

#resource "aws_internet_gateway_attachment" "attach_igw" {
#  internet_gateway_id = aws_internet_gateway.vpc_igw.id
#  vpc_id = aws_vpc.vpc.id
#}

resource "aws_route" "public_igw_route"{
  route_table_id = aws_default_route_table.main.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.vpc_igw.id
}

resource "aws_eip" "nat_eip" {
  vpc = true
}

resource "aws_nat_gateway" "vpc_ngw" {
  allocation_id = aws_eip.nat_eip.allocation_id
  subnet_id = aws_subnet.subnets[0].id
  tags = {
    Name = "${var.env}-natgateway"
  }
  #depends_on = [aws_internet_gateway.vpc_igw]
}

resource "aws_route" "private_nat_route"{
  route_table_id = aws_route_table.custom.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.vpc_ngw.id
}

resource "aws_security_group" "east1_default" {
  name = "${var.env}-defaultsg"
  vpc_id = aws_vpc.vpc.id
  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    #cidr_blocks = ["35.129.109.0/24"]
    cidr_blocks = ["35.129.109.244/32"]
  }
  ingress {
    description = "HTTP"
    from_port = 80
    to_port = 80
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = "true"
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "${var.env}-defaultsg"
    "kubernetes.io/cluster/${var.eksclustername}" = "owned"
  }
}

resource "aws_security_group" "east1_private" {
  name = "${var.env}-private"
  vpc_id = aws_vpc.vpc.id
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_groups = [aws_security_group.east1_default.id]
    self = "true"
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.env}-privatesg"
    "kubernetes.io/cluster/${var.eksclustername}" = "owned"
  }
  depends_on = [aws_vpc.vpc]
}
