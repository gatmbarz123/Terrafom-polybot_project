output "sqs_url"{
    value = module.vpc.sqs_url
    description = "The URL of ths SQS"
    sensitive = true
}

output "dynamodb_name"{
    value = module.vpc.dynamodb_name
    description = "The Name of ths DB"
}

output "s3_name"{
    value = module.vpc.s3_name
    description = "The Name of ths S3"
}


output "alb_url" {
    value       = module.alb.alb_url
    description = "The URL for the ALB"
}

output "instance_public_ips" {
    value       =  module.polybot.instance_public_ips
    description = "The public ips of the polybots "
}

