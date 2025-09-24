variable "key_name" {
  description = "EC2 key pair name for SSH access to the bastion host"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the bastion host"
  type        = string
}

variable "alb_sg_id" {
  description = "Security group ID for the Alb security group to allow SSH access"
  type        = string
}
variable "name_prefix" {
  description = "Prefix for all resources created"
  type        = string
}