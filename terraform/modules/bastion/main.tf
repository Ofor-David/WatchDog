resource "aws_instance" "bastion" {
  depends_on                  = [data.aws_ami.ubuntu]
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.alb_sg_id]
  associate_public_ip_address = true
  tags = {
    Name = "${var.name_prefix}-bastion"
  }
}
# Lookup the latest Ubuntu 22.04 LTS AMI in your region
data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"] # Canonical (official Ubuntu AMI publisher)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
