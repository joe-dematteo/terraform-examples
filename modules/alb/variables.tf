variable "eks_cluster_endpoint" {
  description = "The endpoint for the EKS cluster."
}

variable "eks_cluster_cert" {
  description = "The certificate for the EKS cluster."
}

variable "eks_cluster_name" {
  description = "The name of the EKS cluster."
}

variable "iam_role_arn" {
  description = "The ARN of the IAM role for the ALB controller."
}

variable "node_groups" {
  description = "The node groups for the EKS cluster."
}

variable "policy" {
  description = "The policy for the IAM role."
}

variable "eks_cluster_oidc_provider_arn" {
  description = "The OIDC provider ARN of the EKS cluster."
  type        = string
}
