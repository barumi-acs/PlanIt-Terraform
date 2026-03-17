data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

data "aws_iam_policy_document" "bastion_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "bastion" {
  name               = "${var.project_name}-Bastion-Role"
  assume_role_policy = data.aws_iam_policy_document.bastion_assume_role.json
}

resource "aws_iam_role_policy" "bastion_eks_access" {
  name = "${var.project_name}-Bastion-EKS-Access"
  role = aws_iam_role.bastion.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "bastion" {
  name = "${var.project_name}-Bastion-Profile"
  role = aws_iam_role.bastion.name
}

resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "this" {
  key_name   = "${var.project_name}-key"
  public_key = tls_private_key.this.public_key_openssh
}

resource "local_sensitive_file" "private_key" {
  content         = tls_private_key.this.private_key_pem
  filename        = "${path.root}/${var.project_name}-key.pem"
  file_permission = "0400"
}

resource "aws_instance" "this" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = "t3.micro"
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [var.bastion_security_group_id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.this.key_name
  iam_instance_profile        = aws_iam_instance_profile.bastion.name
  user_data_replace_on_change = true

user_data = <<-EOF
#!/bin/bash
  set -euxo pipefail

  exec > >(tee /var/log/bastion-bootstrap.log | logger -t bastion-bootstrap -s 2>/dev/console) 2>&1

  retry() {
    local n=0
    local max=5
    local delay=5
    until "$@"; do
      n=$((n+1))
      if [ "$n" -ge "$max" ]; then
        return 1
      fi
      sleep "$delay"
    done
  }

  retry dnf install -y --allowerasing curl unzip tar ca-certificates

  if ! command -v aws >/dev/null 2>&1; then
    retry dnf install -y awscli
  fi

# 팩트: 이 부분 전체를 공백 없이 왼쪽으로 완전히 밀착시켜야 함!
cat >/etc/yum.repos.d/kubernetes.repo <<'REPO'
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/repodata/repomd.xml.key
REPO

  retry dnf install -y kubectl
  kubectl version --client=true

su - ec2-user -c "aws eks update-kubeconfig --region ap-northeast-2 --name PI-DEV-Cluster"

retry dnf install -y bash-completion
echo "source <(kubectl completion bash)" >> /home/ec2-user/.bashrc

EOF

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name = "${var.project_name}-Bastion"
  }
}
