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
    values = ["al2023-ami-ecs-hvm-*-kernel-6.1-x86_64"]
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
  }

  block_device_mappings {
    device_name = "/dev/xvda" # Default device name for ECS optimized AMI
    ebs {
      volume_size           = var.volume_size
      volume_type           = "gp2"
      delete_on_termination = true
    }
  }

  user_data = base64encode(<<EOF
#!/bin/bash
set -xe

# Register ECS cluster
echo ECS_CLUSTER=${var.name}-cluster >> /etc/ecs/ecs.config

# Update system
dnf update -y

# Install dependencies
dnf install -y wget jq amazon-cloudwatch-agent

# Trust Falco GPG key
rpm --import https://falco.org/repo/falcosecurity-packages.asc

# Add Falco repo
wget -O /etc/yum.repos.d/falcosecurity.repo https://falco.org/repo/falcosecurity-rpm.repo

# Update repo metadata
dnf makecache

# Update package list
dnf update -y

# Install build deps for driver (kmod/eBPF)
dnf install -y dkms make kernel-devel-$(uname -r) clang llvm cronie

# Install Falco (noninteractive, let it auto-pick driver)
FALCO_FRONTEND=noninteractive dnf install -y falco

# Disable falcoctl auto-updates
systemctl mask falcoctl-artifact-follow.service || true

# Script to sync rules from S3
cat <<'EOS' > /usr/local/bin/falco-update-rules.sh
#!/bin/bash
aws s3 cp s3://${var.falco_bucket_name}/${var.custom_rules_object_key} /etc/falco/falco_rules.local.yaml
systemctl restart falco
EOS
chmod +x /usr/local/bin/falco-update-rules.sh

# Systemd service to manually update rules
cat <<EOT > /etc/systemd/system/falco-update-rules.service
[Unit]
Description=Update Falco Rules from S3

[Service]
Type=oneshot
ExecStart=/usr/local/bin/falco-update-rules.sh
EOT

# Cronjob for rule updates every night at 3 AM
sudo mkdir -p /etc/cron.d
cat <<EOT | sudo tee /etc/cron.d/falco-update
0 3 * * * root /usr/local/bin/falco-update-rules.sh
EOT
sudo systemctl enable crond
sudo systemctl start crond

# Enable and start Falco (modern eBPF is default auto choice)
sudo systemctl daemon-reload
sudo systemctl start falco
EOF
  )

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.name}-lt"
  }
}
