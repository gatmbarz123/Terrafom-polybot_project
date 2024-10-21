output "instance_id" {
  value = aws_instance.polybot[*].id
  description = "The ID of the example EC2 instance."
}

output "instance_public_ips" {
  value = aws_instance.polybot[*].public_ip
  description = "The ID of the example EC2 instance."
}
