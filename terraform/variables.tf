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

variable "healtcheck_path" {
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

variable "instance_min_count" {
  description = "Minimum number of instances in the ASG"
  type        = number
  default     = 1
}

variable "instance_max_count" {
  description = "Maximum number of instances in the ASG"
  type        = number
  default     = 2
}

variable "instance_volume_size" {
  description = "EBS volume size for each instance in the ASG"
  type        = number
  default     = 30
}

variable "max_instance_lifetime" {
  description = "Auto terminate and replace instances when they reach this age"
  type        = number
  default     = 604800 #7 days
}

variable "instance_cpu_target" {
  description = "Target average CPU utilization for ECS instance autoscaling"
  type        = number
  default     = 40
}
variable "domain_name" {
  description = "The domain name for the ACM certificate"
  type        = string
}

variable "your_local_ip" {
  description = "Your local machine's public IP address for SSH access to the ALB security group"
  type        = string
}

variable "falco_log_retention_duration" {
  description = "Number of days to retain logs in CloudWatch Log Group for Falco"
  type        = number
  default     = 30
}

variable "cron_schedule" {
  description = "Cron schedule for falco rule updates"
  type        = string
  default     = "0 3 * * *"  # Daily at 3 AM UTC
}

variable "slack_webhook_url"{
  description = "Slack webhook URL for falco alerts"
  type = string
}

variable "slack_channel_name"{
description = "Slack channel name for falco alerts"
type = string
}

variable "slack_username"{
  description = "Slack username for falco alerts"
  type = string
}

variable "use_grafana" {
  description = "Whether to create a Grafana workspace"
  type        = bool
  default     = false
}