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
  region = "eu-north-1"  
}

module "vpc" {
  source = "./module/common"
  s3_name = var.s3_name
  dynamodb_name = var.dynamodb_name
  sqs_name  = var.sqs_name
}

module "polybot" {
    source = "./module/polybot"
    ami_id             = data.aws_ami.ubuntu_ami.id 
    instance_type      = var.instance_type
    key_pairs           = var.key_pairs
    vpc_id = module.vpc.vpc_id 
    subnet_id = module.vpc.public_subnets
    
}

module "alb"{
    source  =  "./module/alb"
    public_subnets = module.vpc.public_subnets
    vpc_id  = module.vpc.vpc_id
    instance_id = module.polybot.instance_id
    record_name = var.record_name
    certificate_arn = var.certificate_arn
}



module "yolo5" {
    source = "./module/yolo5"
    ami_id             = data.aws_ami.ubuntu_ami.id 
    instance_type      = var.instance_type
    key_pairs           = var.key_pairs
    vpc_id = module.vpc.vpc_id 
    subnet_id = module.vpc.public_subnets
    private_key_path  = var.private_key_path
}