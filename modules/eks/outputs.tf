

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "oidc_provider_url" {
  value = module.eks.cluster_oidc_issuer_url
}

output "cluster_ca_certificate" {
  value = module.eks.cluster_certificate_authority_data
}

output "managed_node_groups" {
  value = module.eks.eks_managed_node_groups
}
