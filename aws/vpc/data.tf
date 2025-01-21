#use it as this ${data.aws_region.current.name} ${data.aws_caller_identity.current.account_id}
locals {
  #az_names = data.aws_availability_zones.default.zone_ids
  az_names = contains(data.aws_availability_zones.default.zone_ids, "use1-az3") ? setsubtract(data.aws_availability_zones.default.zone_ids, ["use1-az3"]) : data.aws_availability_zones.default.zone_ids
}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_vpc" "default" {
  filter {
    name   = "vpc-id"
    values = [aws_vpc.vpc.id]
  }
}

data "aws_availability_zones" "default" {
  #all_availability_zones = true
  filter {
    name = "opt-in-status"
    #values = ["not-opted-in", "opted-in"]
    values = ["opt-in-not-required"]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name = "map-public-ip-on-launch"
    values = ["true"]
  }
}

#data "aws_subnet" "public" {
#  for_each = toset(aws_subnets.public.ids)
#  id = each.value 
#}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name = "map-public-ip-on-launch"
    values = ["false"]
  }
}

#data "aws_subnet" "private" {
#  for_each = toset(aws_subnets.private.ids)
#  id = each.value 
#}

data "aws_route_table" "main" {
  filter {
    name = "association.main"
    values = ["true"]
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_security_group" "default" {
  filter {
    name = "group-name"
    values = ["default"]
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

