variable "instance_type" {
   description = "instance_type"
   type        = string
}
variable "key_pairs" {
   description = "key_name"
   type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}


variable "subnet_id" {
  description = "List of public subnets"
  type        = list(string)
}

variable "private_key"{
   description = "The private path key aws"
   type        = string
}

variable "aws_region"{
   description = "The region aws"
   type        = string
}

variable "s3_name" {
   description = "s3_name"
   type        = string
}
variable "dynamodb_name" {
   description = "dynamodb_name"
   type        = string
}

variable "sqs_name" {
   description = "sqs_name"
   type        = string
}

variable "alb_url" {
   description = "alb_url"
   type        = string
}

