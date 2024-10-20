module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  name = "TelegramBot"
  cidr = "10.0.0.0/16"
  map_public_ip_on_launch = true

  azs             = ["eu-north-1a","eu-north-1b"]
  public_subnets  = ["10.0.1.0/24","10.0.2.0/24"]
  
  enable_nat_gateway = false
}


resource "aws_sqs_queue" "polybot_sqs"{
  name = var.sqs_name
}

resource "aws_s3_bucket" "bot_bucket" {
  bucket = var.s3_name
}

resource "aws_dynamodb_table" "dynamodb_bot" {
    name         = var.dynamodb_name
    billing_mode = "PAY_PER_REQUEST"
    attribute {
        name = "prediction_id"  
        type = "S"              
    }
    hash_key = "prediction_id"
}
