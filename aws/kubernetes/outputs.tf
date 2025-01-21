output "aws_availability_zones_id" {
  value = data.aws_availability_zones.default.id
}

output "aws_availability_zones_name" {
  value = data.aws_availability_zones.default.names
}

output "aws_availzones" {
  value = data.aws_availability_zones.default.zone_ids
}

output "aws_ami" {
  value = data.aws_ami.eks.image_id
}

output "aws_auth" {
  value = data.kubernetes_config_map.aws-auth.data.mapRoles
}

output "public_subnets" {
  value = data.aws_subnets.public.ids
}

output "private_subnets" {
  value = data.aws_subnets.private.ids
}
