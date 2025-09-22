variable "aws_access_key" {
  description = "AWS Access Key"
  type        = string
  sensitive   = true

}
variable "aws_secret_key" {
  description = "AWS Secret Key"
  type        = string
  sensitive   = true

}
variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"

}

variable "app_name" {
  description = "Name of the application"
  type        = string
}

variable "instance_type" {
  description = "instance_type for the ECS cluster"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Name of the SSH key pair to use for EC2 instances"
  type        = string
}

variable "ecr_image_uri" {
  description = "ECR image URL"
  type        = string
  
}

variable "healtcheck_path"{
  description = "Health check path for the ALB"
  type        = string
  default     = "/api"
}

variable "cpu_per_task" {
    description = "The number of CPU units used by the task"
    type        = number
    default     = 256
}

variable "memory_per_task" {
    description = "The amount of memory (in MiB) used by the task"
    type        = number
    default     = 512
}

variable "service_min_capacity" {
    description = "Minimum number of ECS service tasks"
    type        = number
    default     = 1
}

variable "service_desired_capacity" {
    description = "Initial desired number of ECS service tasks"
    type        = number
    default     = 1
}

variable "service_max_capacity" {
    description = "Maximum number of ECS service tasks"
    type        = number
    default     = 3
}

variable "service_cpu_target" {
    description = "Target average CPU utilization for ECS service autoscaling"
    type        = number
    default     = 50
}

variable "instance_min_count"{
  description = "Minimum number of instances in the ASG"
  type        = number
  default     = 0
}

variable "instance_max_count"{
  description = "Maximum number of instances in the ASG"
  type        = number
  default     = 2
}

variable "instance_cpu_target" {
    description = "Target average CPU utilization for ECS instance autoscaling"
    type        = number
    default     = 40
} 
variable "domain_name"{
  description = "The domain name for the ACM certificate"
  type        = string
}