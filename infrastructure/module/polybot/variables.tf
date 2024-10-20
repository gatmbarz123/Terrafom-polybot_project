variable "ami_id" {
   description = "ami_id"
   type        = string

}
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





