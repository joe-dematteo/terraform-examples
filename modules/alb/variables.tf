variable "eks_cluster_endpoint" {
  description = "The endpoint for the EKS cluster."
}

variable "eks_cluster_cert" {
  description = "The certificate for the EKS cluster."
}

variable "eks_cluster_name" {
  description = "The name of the EKS cluster."
}

variable "node_groups" {
  description = "The node groups for the EKS cluster."
}

variable "eks_cluster_oidc_provider_arn" {
  description = "The OIDC provider ARN of the EKS cluster."
  type        = string
}
