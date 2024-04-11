variable "name" {
  description = "Name of the EKS cluster"
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "private_subnets" {
  description = "Private subnets"
  type        = list(string)
}

variable "intra_subnets" {
  description = "Intra subnets"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to the resources"
  type        = map(string)
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name                   = var.name
  cluster_version                = "1.29"
  cluster_endpoint_public_access = true


  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  enable_efa_support = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent    = true
      before_compute = true
      configuration_values = jsonencode({
        env = {
          # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
  }

  vpc_id                   = var.vpc_id
  subnet_ids               = var.private_subnets
  control_plane_subnet_ids = var.intra_subnets

  create_iam_role          = true
  iam_role_name            = "eks-cluster-${var.name}"
  iam_role_use_name_prefix = false
  iam_role_description     = "EKS cluster role"

  iam_role_additional_policies = {
    AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  }


  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    instance_types = ["t3a.xlarge", "t2.large", "t2.medium"]

    attach_cluster_primary_security_group = true
  }



  eks_managed_node_groups = {
    overflow-cluster-wg = {
      min_size     = 1
      max_size     = 10
      desired_size = 1

      disk_size = 20

      instance_types = ["t2.medium"]
      capacity_type  = "SPOT"
    }

  }

  tags = var.tags
}
