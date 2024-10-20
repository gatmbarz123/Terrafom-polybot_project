variable "public_subnets" {
  description = "List of public subnets"
  type        = list(string)
  default     = [] 
}

variable "instance_id"{
  type  = list
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string

}

variable "record_name" {
  description = "The record name"
  type        = string

}

variable "certificate_arn" {
  description = "The certificate arn"
  type        = string

}
