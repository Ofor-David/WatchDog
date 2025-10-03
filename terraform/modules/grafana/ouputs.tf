output "grafana_workspace_endpoint" {
  description = "The endpoint of the Grafana workspace"
  value       = aws_grafana_workspace.watchdog.endpoint
}