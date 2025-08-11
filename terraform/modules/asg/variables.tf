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