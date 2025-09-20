output "ecs_cp_name" {
  value       = aws_ecs_capacity_provider.ecs_cp.name
  description = "The name of the ECS capacity provider created for the ASG"
}

output "asg_name" {
  value       = aws_autoscaling_group.ecs_asg.name
  description = "The name of the Auto Scaling Group created"
}
