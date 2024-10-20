output "public_subnets" {
  value       = module.vpc.public_subnets
  description = "a list of the all public subnet 1"
}

output "vpc_id" {
  value = module.vpc.vpc_id
  description = "The ID of the VPC"
}


