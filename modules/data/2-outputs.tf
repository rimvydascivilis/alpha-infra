output "available_azs" {
  value = data.aws_availability_zones.available.names
}

output "first_3_azs" {
  value = slice(data.aws_availability_zones.available.names, 0, 3)
}