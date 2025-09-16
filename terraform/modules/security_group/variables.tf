variable "name" {
  description = "Prefix for the security group name"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the security group will be created"
  type        = string
}