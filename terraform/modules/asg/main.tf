resource "aws_autoscaling_group" "ecs_asg" {
  depends_on = [var.ecs_cluster]
  desired_capacity     = 2
  max_size             = 4
  min_size             = 1
  vpc_zone_identifier  = var.subnet_ids
  protect_from_scale_in = false # Prevents instances from being terminated during scale-in operations. i.e when scaling down.
  target_group_arns = var.lb_target_group_arns
  health_check_type = "ELB"
  health_check_grace_period = 300 # Time to wait before checking health of instances after launch
  force_delete = true
  launch_template {
    id      = var.launch_template_id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.name}-instances"
    propagate_at_launch = true # This tag will be applied to instances launched by this ASG
  }
}

# Capacity provider for the ASG
resource "aws_ecs_capacity_provider" "ecs_cp" {
  name = "${var.name}-ecs-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs_asg.arn
    managed_termination_protection = "DISABLED" # Prevents instances from being terminated by ECS

    managed_scaling {
      status                    = "ENABLED"
      target_capacity           = 100 # Percentage of the ASG's desired capacity to maintain before scaling
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 2
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "ecs_cp_attach" {
  cluster_name       = var.ecs_cluster_name
  capacity_providers = [aws_ecs_capacity_provider.ecs_cp.name]
}

