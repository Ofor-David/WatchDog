output "ecr_repo_name" {
  description = "The URL of the ECR repository"
  value       = module.ecr.repo_name
}

output "curl_testing_app_url" {
  description = "curl testing app url"
  value       = "curl -kv https://${module.alb.alb_dns_name}/api"
}

output "falco_bucket_name"{
  description = "The name of the S3 bucket for Falco rules"
  value = module.falco.falco_bucket_name
}

output "bastion_ssh_command" {
  description = "command to ssh to bastion host"
  value       = "\nscp -i ${var.key_name}.pem ${var.key_name}.pem ubuntu@${module.bastion.bastion_public_dns}:/home/ubuntu/\nssh -i ${var.key_name}.pem ubuntu@${module.bastion.bastion_public_dns}"
}

output "grafana_workspace_endpoint" {
  description = "The endpoint of the Grafana workspace"
  value = var.use_grafana ? "https://${module.grafana.grafana_workspace_endpoint}" : "Enable grafana in variables.tf to create a workspace"
}

output "inspection_tag"{
    description = "The tag used to mark instances for inspection"
    value       = module.lambda.inspection_tag
}