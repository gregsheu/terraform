output "vpc" {
  value = data.aws_vpc.default.id
}

output "azs" {
  value = data.aws_availability_zones.default.zone_ids
}

output "public_subnets" {
  value = data.aws_subnets.public.ids
}

output "private_subnets" {
  value = data.aws_subnets.private.ids
}

output "vpc_cidr" {
  value = data.aws_vpc.default.cidr_block
}

#output "public_subnet_cidr_blocks" {
#  value = [for s in data.aws_subnet.public: s.cidr_block]
#}

#output "private_subnet_cidr_blocks" {
#  value = [for s in data.aws_subnet.private: s.cidr_block]
#}

output "main_route_table_id" {
  value = data.aws_route_table.main.id
}

output "default_security_group_id" {
  value = data.aws_security_group.default.id
}
