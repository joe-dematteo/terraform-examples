locals {
  name       = basename(path.cwd)
  vpc_cidr   = "10.0.0.0/16"
  azs        = ["us-east-1a", "us-east-1b", "us-east-1c"]
  region     = "us-east-1"
  repository = basename(path.cwd)

  tags = {
    Application = local.name
    CreatedBy   = "Terraform"
    DeployedBy  = data.aws_caller_identity.current.arn
    Environment = var.env
    Repository  = local.repository
  }
}


terraform {
  required_version = "~> 1.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.40"
    }
  }

}

provider "aws" {
  region  = local.region
  profile = var.profile
}

data "aws_caller_identity" "current" {

}

module "ecs" {
  source = "./modules/ecs"

  cluster_name              = local.name
  target_group_backend_port = 80
  vpc_cidr                  = local.vpc_cidr
  azs                       = local.azs
  tags                      = local.tags
}
