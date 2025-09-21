resource "aws_ecs_task_definition" "ecs_task_def" {
  family                   = var.family
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = var.image_uri
      cpu       = var.cpu
      memory    = var.memory
      essential = true
      portMappings = [
        {
          containerPort = 8000
          hostPort      = 0 # Dynamic host port - ECS will assign available port
          protocol      = "tcp"
        }
      ]
    }
  ])

  tags = {
    Name = "${var.family}-task-def"
  }
}

resource "aws_ecs_service" "ecs_service" {
  name            = "${var.family}-service"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.ecs_task_def.arn
  desired_count   = var.desired_count
  # launch_type = "EC2" # Using capacity providers instead
  depends_on = [var.lb_tg]

  capacity_provider_strategy {
    capacity_provider = var.ecs_cp_name
    weight            = 1 # Just to ensure that this capacity provider is used, modify this if you have multiple providers
    base              = 0 # Number of tasks to run on this capacity provider before considering others
  }
  deployment_minimum_healthy_percent = 50  # Minimum healthy percent during deployment
  deployment_maximum_percent         = 200 # Allow up to 200% (double) tasks temporarily for safe rollouts.

  load_balancer {
    target_group_arn = var.lb_tg
    container_name   = var.container_name
    container_port   = 8000
  }
  tags = {
    Name = "${var.family}-service"
  }
}

# Application Auto Scaling for ECS Service desired count (CPU target tracking)
resource "aws_appautoscaling_target" "ecs_service_desired_count" {
  max_capacity       = var.service_max_capacity
  min_capacity       = var.service_min_capacity
  resource_id        = "service/${var.cluster_name}/${aws_ecs_service.ecs_service.name}" # Identifies the ECS service to scale
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_service_cpu_policy" {
  name               = "${var.family}-cpu-target"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_service_desired_count.resource_id        # Identifies the ECS service to scale
  scalable_dimension = aws_appautoscaling_target.ecs_service_desired_count.scalable_dimension # The dimension to scale, here it's the desired count of the ECS service
  service_namespace  = aws_appautoscaling_target.ecs_service_desired_count.service_namespace  # The namespace for ECS

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.service_cpu_target
    scale_in_cooldown  = 30 # Seconds to wait after a scale-in activity before another scaling activity can start
    scale_out_cooldown = 30 # Seconds to wait after a scale-out activity before another scaling activity can start
  }
}

# ASG instance autoscaling
resource "aws_autoscaling_policy" "ecs_asg_cpu_scale" {
  name                   = "ecs-asg-cpu-target"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = var.asg_name
  estimated_instance_warmup = 300
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = var.instance_cpu_target # adjust to taste
  }
}
