terraform {
  required_version = ">= 1.5.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.2"
    }
  }
}

provider "kubernetes" {
  config_path    = pathexpand("~/.kube/config")
  config_context = var.kube_context
}

resource "kubernetes_namespace_v1" "sentinel" {
  metadata {
    name = var.namespace

    labels = {
      "app.kubernetes.io/part-of"    = "sentinel"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

module "sentinel_server" {
  source = "../../modules/sentinel_server"

  namespace = kubernetes_namespace_v1.sentinel.metadata[0].name
  image     = var.server_image
  port      = var.server_port
}

module "sentinel_agent" {
  source = "../../modules/sentinel_agent"

  namespace     = kubernetes_namespace_v1.sentinel.metadata[0].name
  image         = var.agent_image
  replicas      = var.agent_replicas
  server_target = "${module.sentinel_server.service_name}.${kubernetes_namespace_v1.sentinel.metadata[0].name}.svc.cluster.local:${var.server_port}"
}
