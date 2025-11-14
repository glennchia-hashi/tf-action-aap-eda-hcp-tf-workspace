resource "aws_instance" "tf_aap" {
  ami                         = data.aws_ssm_parameter.al_2023_x86.value
  instance_type               = var.instance_type
  iam_instance_profile        = aws_iam_instance_profile.ec2_tf_aap.name
  subnet_id                   = aws_subnet.tf_aap_public1.id
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.ec2_tf_aap.id]

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required" # Enforces IMDSv2
  }

  user_data = <<-EOF
#!/bin/bash

useradd -m -s /bin/bash "${var.ssh_username}"
echo "${var.ssh_username}:${var.ssh_password}" | chpasswd
usermod -aG sudo "${var.ssh_username}"
echo "${var.ssh_username} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${var.ssh_username}
sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/" /etc/ssh/sshd_config

systemctl restart sshd
EOF

  lifecycle {
    action_trigger {
      events  = [after_create]
      actions = [action.aap_eda_eventstream_post.create]
    }
  }

  tags = {
    Name = "${var.tf_aap_resource_prefix}-ec2"
  }
}

resource "aws_security_group" "ec2_tf_aap" {
  name_prefix = "${var.tf_aap_resource_prefix}-sg"
  description = "Security group for tf-aap EC2"
  vpc_id      = aws_vpc.tf_aap.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "ec2_tf_aap_22_allowed_ip" {
  security_group_id = aws_security_group.ec2_tf_aap.id
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = var.ssh_aap_ip
  description       = "allow ${var.ssh_aap_ip} for 22"

  tags = {
    Name = "allow-${var.ssh_aap_ip}-22"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ec2_tf_aap_80_allowed_ip" {
  security_group_id = aws_security_group.ec2_tf_aap.id
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = var.http_allowed_ip
  description       = "allow ${var.http_allowed_ip} for 80"

  tags = {
    Name = "allow-${var.http_allowed_ip}-80"
  }
}

resource "aws_vpc_security_group_egress_rule" "ec2_tf_aap_443_all" {
  security_group_id = aws_security_group.ec2_tf_aap.id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
  description       = "All 443"

  tags = {
    Name = "all-443"
  }
}

resource "aws_iam_role" "ec2_tf_aap" {
  name = "${var.tf_aap_resource_prefix}-role"

  assume_role_policy = data.aws_iam_policy_document.ec2_trust.json
}

resource "aws_iam_instance_profile" "ec2_tf_aap" {
  name = "${var.tf_aap_resource_prefix}-profile"
  role = aws_iam_role.ec2_tf_aap.name
}

resource "aws_iam_role_policy_attachment" "ec2_tf_aap_ssm" {
  policy_arn = data.aws_iam_policy.amazon_ssm_managed_instance_core.arn
  role       = aws_iam_role.ec2_tf_aap.name
}
