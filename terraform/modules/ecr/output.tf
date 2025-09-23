output "repo_url" {
  description = "The URL of the ECR repository"
  value       = aws_ecr_repository.ecr_repo.repository_url
}

output "repo_name"{
  description = "The name of the ECR repository"
  value       = aws_ecr_repository.ecr_repo.name
}