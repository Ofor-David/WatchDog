variable "name" {
  type        = string
  description = "Name prefix for ALB resources"
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
  description = "List of public subnet IDs across AZs (min 2)"
}

variable "target_port" {
  type    = number
}

variable "health_check_path" {
  type    = string
  default = "/health"
}
