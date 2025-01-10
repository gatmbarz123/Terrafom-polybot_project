terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.55"
    }
  }

   backend "s3" {
    bucket = "terraform.bot.bar"
    key    = "tfstate.json"
    region = "eu-north-1"
  
  }

  required_version = ">= 1.7.0"
}

provider "aws" {
  region = var.aws_region  
}

module "vpc" {
  source = "./module/common"
  s3_name = "polybot.s3.bucket"
  dynamodb_name = "AIbot"
  sqs_name  = "polyBotSQS"
}

module "polybot" {
    source = "./module/polybot"
    instance_type      = "t3.micro"
    key_pairs           = "StockKey"
    vpc_id = module.vpc.vpc_id 
    subnet_id = module.vpc.public_subnets
    
}

module "alb"{
    source  =  "./module/alb"
    public_subnets = module.vpc.public_subnets
    vpc_id  = module.vpc.vpc_id
    instance_id = module.polybot.instance_id
    record_name = "alb.bargutman.click"
    certificate_arn = var.certificate_arn
}



module "yolo5" {
    source = "./module/yolo5" 
    instance_type      = "t3.micro"
    key_pairs           = "StockKey"
    vpc_id = module.vpc.vpc_id 
    subnet_id = module.vpc.public_subnets
    private_key  = var.private_key
    aws_region  = var.aws_region
    s3_name = module.vpc.s3_name
    dynamodb_name = module.vpc.dynamodb_name
    sqs_name  = module.vpc.sqs_url
    alb_url = module.alb.alb_url
}

module "promethoeus"{
  source  = "./module/prometheus"
  instance_type      = "t3.micro"
  key_pairs           = "StockKey"
  vpc_id = module.vpc.vpc_id 
  subnet_id = module.vpc.public_subnets
  instance_ips = module.polybot.instance_public_ips

}