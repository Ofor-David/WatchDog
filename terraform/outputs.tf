output "ecr_repo_url" {
  description = "The URL of the ECR repository"
  value       = module.ecr.repo_url
}

output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = module.alb.alb_dns_name
}

output "falco_bucket_name"{
  description = "The name of the S3 bucket for Falco rules"
  value = module.falco.falco_bucket_name
}

output "bastion_public_ip" {
  description = "Public IP address of the bastion host"
  value       = module.bastion.bastion_public_ip
}