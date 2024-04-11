variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "app_name" {
  description = "The name of the application"
  type        = string
}

variable "namespace" {
  description = "The namespace to deploy the application"
  type        = string
  default     = "default"
}

variable "image" {
  description = "The Docker image to deploy"
  type        = string
}

variable "replicas" {
  description = "The number of replicas to run"
  type        = number
  default     = 1
}

variable "container_port" {
  description = "Number of port to expose on the pod's IP address. This must be a valid port number, 0 < x < 65536."
  type        = string
}

variable "host_port" {
  description = "Number of port to expose on the host. If specified, this must be a valid port number, 0 < x < 65536. If HostNetwork is specified, this must match ContainerPort. Most containers do not need this."
  type        = string
}

variable "protocol" {
  description = "Protocol for port. Must be UDP or TCP. Default is TCP."
  type        = string
  default     = "TCP"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  #   load_config_file       = false
}

data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}

resource "kubernetes_deployment" "app" {
  metadata {
    name      = var.app_name
    namespace = var.namespace
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = var.app_name
      }
    }

    template {
      metadata {
        labels = {
          app = var.app_name
        }
      }

      spec {
        container {
          name  = var.app_name
          image = var.image

          port {
            protocol       = var.protocol
            container_port = var.container_port
            host_port      = var.host_port
          }
        }
      }
    }
  }
}
