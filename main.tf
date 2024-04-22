locals {
  eks_cluster_name = basename(path.cwd)
  vpc_cidr         = "10.0.0.0/16"
  azs              = ["us-east-1a", "us-east-1b", "us-east-1c"]
}



terraform {
  required_version = "~> 1.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.40"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.13"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
  }

}

provider "aws" {
  region  = var.region
  profile = var.profile
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", local.eks_cluster_name]
      command     = "aws"
    }
  }
}

provider "kubectl" {
  apply_retry_count      = 5
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)
  load_config_file       = false

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", local.eks_cluster_name]
    command     = "aws"
  }
}

module "vpc" {
  source       = "./modules/vpc"
  name         = local.eks_cluster_name
  azs          = local.azs
  vpc_cidr     = local.vpc_cidr
  tags         = module.tags.tags
  cluster_name = local.eks_cluster_name
}

module "eks" {
  source          = "./modules/eks"
  name            = local.eks_cluster_name
  vpc_id          = module.vpc.vpc_id
  intra_subnets   = module.vpc.intra_subnets
  private_subnets = module.vpc.private_subnets
  tags            = module.tags.tags
}

module "alb" {
  source                        = "./modules/alb"
  eks_cluster_cert              = module.eks.cluster_ca_certificate
  eks_cluster_endpoint          = module.eks.cluster_endpoint
  eks_cluster_name              = local.eks_cluster_name
  eks_cluster_oidc_provider_arn = module.eks.oidc_provider_arn
  region                        = var.region
  vpc_id                        = module.vpc.vpc_id
  tags                          = module.tags.tags
}

module "karpenter" {
  source = "./modules/karpenter"

  eks_cluster_name     = local.eks_cluster_name
  eks_cluster_cert     = module.eks.cluster_ca_certificate
  eks_cluster_endpoint = module.eks.cluster_endpoint
  oidc_provider_arn    = module.eks.oidc_provider_arn
  tags                 = module.tags.tags
}

resource "aws_ecr_repository" "ecr" {
  name = local.eks_cluster_name

  tags = module.tags.tags
}

module "tags" {
  source  = "clowdhaus/tags/aws"
  version = ">= 1.0"

  application = local.eks_cluster_name
  environment = var.env
  repository  = "https://github.com/clowdhaus/eks-reference-architecture"
}
