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
    associate_public_ip_address = false
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

FILE="/etc/falco/falco.yaml"

# Use perl to do a multiline, case-sensitive replacement.
# -0777 turns on "slurp" mode so we can match across newlines.
# (?m) enables ^ and $ to match line boundaries; we accept optional CR (\r) for Windows endings.
# The 'g' modifier makes it replace all occurrences in the file.
perl -0777 -pe '
  s{
    (?m)                                   # multiline mode
    ^file_output:\r?\n                     # line starting with file_output:
    [ \t]*enabled:\s*false\r?\n            #   enabled: false
    [ \t]*keep_alive:\s*false\r?\n         #   keep_alive: false
    [ \t]*filename:\s*\./events\.txt\r?\n  #   filename: ./events.txt
  }
  {
    "file_output:\n  enabled: true\n  keep_alive: false\n  filename: /var/log/falco.log\n"
  }gex
' -i.bak "$FILE"

echo "Replacement done in '$FILE' (backup saved as '$FILE.bak')."

# Cronjob for rule updates
sudo mkdir -p /etc/cron.d
cat <<EOT | sudo tee /etc/cron.d/falco-update
${var.cron_schedule} root /usr/local/bin/falco-update-rules.sh
EOT
sudo systemctl enable crond
sudo systemctl start crond

# --- CloudWatch Agent config ---
mkdir -p /opt/aws/amazon-cloudwatch-agent/etc
cat <<EOT > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/falco.log",
            "log_group_name": "${var.falco_log_group_name}",
            "log_stream_name": "{instance_id}-falco",
            "timezone": "UTC"
          }
        ]
      }
    }
  }
}
EOT

./usr/local/bin/falco-update-rules.sh

# Enable and start CloudWatch Agent
sudo systemctl enable amazon-cloudwatch-agent
sudo systemctl restart amazon-cloudwatch-agent

# Enable and start Falco (modern eBPF is default auto choice)
sudo systemctl daemon-reload
sudo systemctl restart falco
EOF
  )

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.name}-lt"
  }
}
