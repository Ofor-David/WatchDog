variable "name" {
  description = "Prefix for the security group name"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the security group will be created"
  type        = string
}

variable "allowed_ips" {
  description = "List of CIDR blocks allowed to access the resources (e.g., for SSH access)"
  type        = list(string)
}

variable "your_local_ip" {
  description = "Your local machine's public IP address for SSH access to the ALB security group"
  type        = string
}