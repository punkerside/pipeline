# cluster
resource "aws_eks_cluster" "this" {
  name                      = "${var.project}-${var.env}"
  role_arn                  = aws_iam_role.this.arn
  version                   = "1.21"

  vpc_config {
    subnet_ids              = aws_subnet.private.*.id
    endpoint_private_access = false
    endpoint_public_access  = true
  }

  tags = {
    Name    = "${var.project}-${var.env}"
    Project = var.project
    Env     = var.env
  }

  timeouts {
    create = "45m"
    delete = "45m"
    update = "45m"
  }
}

resource "aws_iam_role" "this" {
  name = "${var.project}-${var.env}"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["eks.amazonaws.com", "eks-fargate-pods.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    Name    = "${var.project}-${var.env}"
    Project = var.project
    Env     = var.env
  }
}

resource "aws_iam_role_policy_attachment" "this" {
  count      = length(var.policy_arn)
  policy_arn = var.policy_arn[count.index]
  role       = aws_iam_role.this.name
}

resource "aws_eks_fargate_profile" "this" {
  cluster_name           = aws_eks_cluster.this.name
  fargate_profile_name   = "main"
  pod_execution_role_arn = aws_iam_role.this.arn
  subnet_ids             = aws_subnet.private.*.id

  selector {
    namespace = "kube-system"
    labels = {
      k8s-app = "kube-dns"
    }
  }

  selector {
    namespace = "default"
  }
}