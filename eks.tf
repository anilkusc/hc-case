module "eks" {
  source  = "terraform-aws-modules/eks/aws"

  cluster_name = "${local.name}-eks-cluster"
  cluster_version = "1.24"

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"

  }

  cluster_addons = {
    aws-ebs-csi-driver = {
      service_account_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.name}-eks-cluster-ebs-csi-controller"
    }
  }
  eks_managed_node_groups = {
    one = {
      name = "${local.name}-node-group-1"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 3
      desired_size = 2
    }

  }
  tags = local.tags
}

data "aws_caller_identity" "current" {
  
}

module "ebs_csi_controller_role" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "5.11.1"
  create_role                   = true
  role_name                     = "${local.name}-eks-cluster-ebs-csi-controller"
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.ebs_csi_controller.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
}

resource "aws_iam_policy" "ebs_csi_controller" {
  name_prefix = "ebs-csi-controller"
  description = "EKS ebs-csi-controller policy for cluster ${local.name}-eks-cluster"
   policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = [
          "ec2:AttachVolume",
          "ec2:CreateSnapshot",
          "ec2:CreateTags",
          "ec2:CreateVolume",
          "ec2:DeleteSnapshot",
          "ec2:DeleteTags",
          "ec2:DeleteVolume",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeInstances",
          "ec2:DescribeSnapshots",
          "ec2:DescribeTags",
          "ec2:DescribeVolumes",
          "ec2:DetachVolume",
          "ec2:ModifyVolume"
        ]
        Resource = "*"
      },
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