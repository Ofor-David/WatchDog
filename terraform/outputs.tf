output "ecr_repo_name" {
  description = "The URL of the ECR repository"
  value       = module.ecr.repo_name
}

output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = module.alb.alb_dns_name
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