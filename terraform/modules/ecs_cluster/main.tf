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
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
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
echo ECS_CLUSTER=${var.name}-cluster >> /etc/ecs/ecs.config

# Update system
yum update -y

# Install dependencies
yum install -y wget curl jq amazon-cloudwatch-agent

# Install Falco
curl -s https://falco.org/repo/falcosecurity-packages.asc | gpg --dearmor -o /etc/pki/rpm-gpg/FALCO-GPG-KEY
cat <<EOT > /etc/yum.repos.d/falco.repo
[falco]
name=Falco
baseurl=https://download.falco.org/packages/rpm/$releasever/\$basearch
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/FALCO-GPG-KEY
EOT
yum install -y falco

# Systemd service to pull rules
cat <<EOT > /etc/systemd/system/falco-update-rules.service
[Unit]
Description=Update Falco Rules from S3

[Service]
Type=oneshot
ExecStart=/usr/local/bin/falco-update-rules.sh
EOT

# Script to sync rules from S3
cat <<'EOS' > /usr/local/bin/falco-update-rules.sh
#!/bin/bash
aws s3 cp s3://${var.falco_bucket_name}/${var.custom_rules_object_key} /etc/falco/falco_rules.local.yaml
systemctl restart falco
EOS
chmod +x /usr/local/bin/falco-update-rules.sh

# Cronjob for daily rule updates at 3 AM
echo "0 3 * * * root /usr/local/bin/falco-update-rules.sh" > /etc/cron.d/falco-update

# Enable and start Falco
systemctl enable falco
systemctl start falco
systemctl daemon-reload
EOF
  )

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.name}-lt"
  }
}