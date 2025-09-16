variable "family"{
    description = "The name of the ECS task definition family"
    type        = string
}

variable "cpu" {
    description = "The number of CPU units used by the task"
    type        = number
}

variable "memory" {
    description = "The amount of memory (in MiB) used by the task"
    type        = number
}

variable "execution_role_arn" {
    description = "The ARN of the IAM role that allows Amazon ECS to make calls to other AWS services on your behalf"
    type        = string
}

variable "task_role_arn" {
    description = "The ARN of the IAM role that containers in the task can assume"
    type        = string
  
}

variable "container_name" {
    description = "The name of the container in the task definition"
    type        = string
  
}

variable "image_uri" {
    description = "The URL of the container image to use in the task definition"
    type        = string
}


variable "cluster_id" {
    description = "The ID of the ECS cluster where the service will be deployed"
    type        = string
}

variable "desired_count" {
    description = "The number of instantiations of the task to place and keep running in your service"
    type        = number
}

variable "lb_tg" {
  description = "load balancer target group resource to depend on"
  type        = any
}