variable "env" {
  description = "Environment of the resources"
  type        = string
}

variable "profile" {
  description = "AWS profile"
  type        = string
  default     = "default"
}

# variable "access_key" {
#   description = "AWS access key"
#   type        = string
# }

# variable "secret_key" {
#   description = "AWS secret key"
#   type        = string
# }

# variable "eks_cluster_name" {
#   description = "Name of the EKS cluster"
#   type        = string
#   default     = "overflow-infra"
# }
