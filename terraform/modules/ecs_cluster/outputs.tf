output "cluster_name" {
  value = aws_ecs_cluster.ecs_cluster.name
}
output "cluster_id"{
  value = aws_ecs_cluster.ecs_cluster.id
}
output "launch_template_id" {
  value = aws_launch_template.ecs.id
}
output "launch_template_name" {
  value = aws_launch_template.ecs.name
}

output "instance_id" {
  value = aws_instance.ecs_instance.id
}
