output "instance_id" {
  value = aws_instance.polybot[*].id
  description = "The ID of the example EC2 instance."
}