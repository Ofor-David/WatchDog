resource "aws_security_group" "ecs_sg" {
  name = "${var.name}-sg"
  description= "alolow http traffic to ecs instances"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP traffic"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-sg"
  }
  
}