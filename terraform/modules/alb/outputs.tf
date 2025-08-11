output "alb_arn" {
  value = aws_lb.lb.arn
}

output "alb_dns_name" {
  value = aws_lb.lb.dns_name
}

output "target_group_arn" {
  value = aws_lb_target_group.lb_tg.arn
}

output "alb_security_group_id" {
  value = aws_security_group.alb_sg.id
}
