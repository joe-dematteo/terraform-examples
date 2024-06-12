variable "cluster_name" {
  description = "Name of ECS Cluster"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the resources"
  type        = map(string)
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "azs" {
  description = "Availability Zones"
  type        = list(string)
}

variable "target_group_backend_port" {
  description = "Backend port for the target group"
  type        = number
}
