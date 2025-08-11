resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "${var.name}-cluster"
  }
}

data "aws_ami" "ecs_optimized" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["591542846629"] # Amazon ECS Optimized AMI owner ID

}

resource "aws_launch_template" "ecs" {
  name_prefix   = "${var.name}-lt-"
  image_id      = data.aws_ami.ecs_optimized.id
  instance_type = var.instance_type
  key_name      = var.key_name

  iam_instance_profile {
    name = var.instance_profile_name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.security_group_id]
    subnet_id                   = var.public_subnet_id
  }

  user_data = base64encode(<<EOF
#!/bin/bash
echo ECS_CLUSTER=${var.name}-cluster >> /etc/ecs/ecs.config
EOF
  )

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.name}-lt"
  }
}

resource "aws_instance" "ecs_instance" {
  ami                         = data.aws_ami.ecs_optimized.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  iam_instance_profile        = var.instance_profile_name
  associate_public_ip_address = true
  user_data = base64encode(
    <<EOF
#!/bin/bash
echo ECS_CLUSTER=${var.name}-cluster >> /etc/ecs/ecs.config
EOF
  )

  tags = {
    Name = "${var.name}-ecs-ec2"
  }

}
