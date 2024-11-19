output "public_subnets" {
  value       = module.vpc.public_subnets
  description = "a list of the all public subnet 1"
}

output "vpc_id" {
  value = module.vpc.vpc_id
  description = "The ID of the VPC"
}

output "sqs_url"{
  value = aws_sqs_queue.polybot_sqs.id
  description = "The URL of ths SQS"
}

output "dynamodb_name"{
  value = aws_dynamodb_table.dynamodb_bot.name
  description = "The Name of ths DB"
}
output "s3_name"{
  value = aws_s3_bucket.bot_bucket.bucket
  description = "The Name of ths S3"
}


