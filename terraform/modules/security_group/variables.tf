variable "name" {
  description = "Prefix for the security group name"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the security group will be created"
  type        = string
}

variable "alb_security_group_id" {
  description = "The security group ID of the ALB"
  type        = string
}