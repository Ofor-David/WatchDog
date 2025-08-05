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
  default     = "watchdog"
  
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