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


variable "instance_ips"{
  type  = list(string)
}

variable "private_key"{
   description = "The private path key aws"
   type        = string
}