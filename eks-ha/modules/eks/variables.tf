
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


