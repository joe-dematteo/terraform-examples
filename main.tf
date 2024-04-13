locals {
  vpc_cidr = "10.0.0.0/16"
  azs      = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

provider "aws" {
  region  = var.region
  profile = var.profile
  # access_key = var.access_key
  # secret_key = var.secret_key
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.40"
    }
  }
}


resource "aws_ecr_repository" "ecr" {
  name = var.eks_cluster_name

  tags = module.tags.tags
}

module "alb" {
  source                        = "./modules/alb"
  eks_cluster_cert              = module.eks.cluster_ca_certificate
  eks_cluster_endpoint          = module.eks.cluster_endpoint
  eks_cluster_name              = var.eks_cluster_name
  eks_cluster_oidc_provider_arn = module.eks.oidc_provider_arn
  node_groups                   = module.eks.managed_node_groups
}


module "eks" {
  source          = "./modules/eks"
  name            = var.eks_cluster_name
  vpc_id          = module.vpc.vpc_id
  intra_subnets   = module.vpc.intra_subnets
  private_subnets = module.vpc.private_subnets
  tags            = module.tags.tags
}


module "vpc" {
  source       = "./modules/vpc"
  name         = var.eks_cluster_name
  azs          = local.azs
  vpc_cidr     = local.vpc_cidr
  tags         = module.tags.tags
  cluster_name = var.eks_cluster_name
}

module "key_pair" {
  source  = "terraform-aws-modules/key-pair/aws"
  version = "~> 2.0"

  key_name_prefix    = var.eks_cluster_name
  create_private_key = true

  tags = module.tags.tags
}

module "tags" {
  source  = "clowdhaus/tags/aws"
  version = "~> 1.0"

  application = var.eks_cluster_name
  environment = var.env
  repository  = "https://github.com/clowdhaus/eks-reference-architecture"
}
