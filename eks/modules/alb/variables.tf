variable "eks_cluster_endpoint" {
  description = "The endpoint for the EKS cluster."
  type        = string
}

variable "eks_cluster_cert" {
  description = "The certificate for the EKS cluster."
}

variable "eks_cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
}

variable "eks_cluster_oidc_provider_arn" {
  description = "The OIDC provider ARN of the EKS cluster."
  type        = string
}

variable "tags" {
  description = "Tags to apply to the resources."
  type        = map(string)
}

variable "region" {
  description = "The region in which the resources will be created."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC."
  type        = string
}
