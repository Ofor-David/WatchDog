variable "launch_template_id" {
  description = "ID of the launch template for ASG"
  type        = string  
}

variable "name" {
  description = "Name prefix for ASG resources"
  type        = string
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "subnet_ids" {
  description = "subnet ids of ecs"
  type = list(string)
  
}

variable "lb_target_group_arns" {
  description = "List of target group ARNs to attach to the ASG"
  type        = set(string)
}

variable "ecs_cluster" {
  description = "ECS cluster resource"
  type = any
}

variable "instance_max_count" {
  description = "Maximum number of instances in the ASG"
  type        = number
  default     = 2
}

variable "instance_min_count" {
  description = "Minimum number of instances in the ASG"
  type        = number
  default     = 1
}

variable "max_instance_lifetime"{
  description = "Auto terminate and replace instances when they reach this age"
  type = number
}