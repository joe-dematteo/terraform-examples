
variable "eks_cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
}

variable "eks_cluster_cert" {
  description = "The certificate authority data for the cluster."
  type        = string
}

variable "eks_cluster_endpoint" {
  description = "The endpoint for the EKS cluster."
  type        = string
}

variable "oidc_provider_arn" {
  description = "The OIDC provider ARN of the EKS cluster."
  type        = string
}

variable "tags" {
  description = "Tags to apply to the resources"
  type        = map(string)
}

