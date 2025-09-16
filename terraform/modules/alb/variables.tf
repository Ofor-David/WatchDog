variable "name" {
  type        = string
  description = "Name prefix for ALB resources"
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs across AZs (min 2)"
}

variable "health_check_path" {
  type    = string
  default = "/health"
}
variable "alb_sg_id" {
  type        = string
  description = "Security group ID for the ALB"
}
