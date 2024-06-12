module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.name
  cluster_version = "1.29"

  # Gives Terraform identity admin access to cluster which will
  # allow deploying resources (Karpenter) into the cluster  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true
  cluster_endpoint_public_access           = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id                   = var.vpc_id
  subnet_ids               = var.private_subnets
  control_plane_subnet_ids = var.intra_subnets

  create_iam_role          = true
  iam_role_name            = "eks-cluster-${var.name}"
  iam_role_use_name_prefix = false
  iam_role_description     = "EKS cluster role"

  enable_irsa                     = true
  include_oidc_root_ca_thumbprint = true

  cluster_security_group_tags = {
    "kubernetes.io/cluster/${var.name}" = "shared"
    "kubernetes.io/role/elb"            = "1"
    "karpenter.sh/discovery"            = var.name
  }

  iam_role_additional_policies = {
    AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  }

  eks_managed_node_groups = {
    karpenter = {
      instance_types = ["t3.medium"]

      min_size     = 1
      max_size     = 3
      desired_size = 1
      taints = {
        # This Taint aims to keep just EKS Addons and Karpenter running on this MNG
        # The pods that do not tolerate this taint should run on nodes created by Karpenter
        addons = {
          key    = "CriticalAddonsOnly"
          value  = "true"
          effect = "NO_SCHEDULE"
        },
      }
    }
  }

  tags = merge(var.tags, {
    # NOTE - if creating multiple security groups with this module, only tag the
    # security group that Karpenter should utilize with the following tag
    # (i.e. - at most, only one security group should have this tag in your account)
    "karpenter.sh/discovery" = var.name
  })
}

