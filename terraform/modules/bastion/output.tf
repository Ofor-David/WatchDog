output "bastion_public_dns" {
  value       = aws_instance.bastion.public_dns
  description = "Public IP address of the bastion host"
}

output "bastion_private_ip"{
    value = aws_instance.bastion.private_ip
    description = "Private IP address of the bastion host"
}
