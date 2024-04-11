variable "env" {
  description = "Environment of the resources"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "profile" {
  description = "AWS profile"
  type        = string
}

# variable "access_key" {
#   description = "AWS access key"
#   type        = string
# }

# variable "secret_key" {
#   description = "AWS secret key"
#   type        = string
# }
