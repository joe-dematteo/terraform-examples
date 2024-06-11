
variable "name" {
  description = "Name of the VPC"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
}

variable "azs" {
  description = "List of availability zones"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to the resources"
  type        = map(string)
}


variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}
