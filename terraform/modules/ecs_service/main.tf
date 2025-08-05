resource "aws_ecs_task_definition" "ecs_task_def" {
    family = var.family
    network_mode = "bridge"
    requires_compatibilities = ["EC2"]
    cpu = var.cpu
    memory = var.memory
    execution_role_arn = var.execution_role_arn
    task_role_arn = var.task_role_arn

    container_definitions = jsonencode([
        {
            name = var.container_name
            image = var.image_uri
            cpu = var.cpu
            memory = var.memory
            essential = true
            portMappings = [
                {
                    containerPort = var.container_port
                    hostPort = var.container_port
                    protocol = "tcp"
                }
            ]
        }
    ])

    tags = {
        Name = "${var.family}-task-def"
    }
}

resource "aws_ecs_service" "ecs_service" {
  name = "${var.family}-service"
  cluster = var.cluster_id
  task_definition = aws_ecs_task_definition.ecs_task_def.arn
  desired_count = var.desired_count
  launch_type = "EC2"

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent = 200

  tags = {
    Name = "${var.family}-service"
  }
}