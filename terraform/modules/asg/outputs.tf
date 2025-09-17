output "ecs_cp_name"{
    value = aws_ecs_capacity_provider.ecs_cp.name
    description = "The name of the ECS capacity provider created for the ASG"
}