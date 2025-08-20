variable "name" {
  description = "Prefix for the security group name"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for the ECS cluster"
  type        = string
}

variable "key_name" {
  description = "EC2 key pair name for SSH access"
  type        = string
}

variable "instance_profile_name" {
  description = "IAM instance profile name for ECS instances"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID to associate with the ECS instances"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID for the ECS instances"
  type        = string
}

variable "ecs_service" {
  description = "ECS service resource to depend on"
  type        = any
}

variable "volume_size" {
  description = "EBS volume size for the ECS instances"
  type        = number
}
