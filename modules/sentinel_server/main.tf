resource "kubernetes_deployment_v1" "server" {
  metadata {
    name      = "sentinel-server"
    namespace = var.namespace
    labels = {
      app = "sentinel-server"
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = "sentinel-server"
      }
    }

    template {
      metadata {
        labels = {
          app = "sentinel-server"
        }
      }

      spec {
        container {
          name              = "server"
          image             = var.image
          image_pull_policy = "IfNotPresent"

          port {
            name           = "grpc"
            container_port = var.port
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "256Mi"
            }
          }

          liveness_probe {
            tcp_socket {
              port = var.port
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }

          readiness_probe {
            tcp_socket {
              port = var.port
            }
            initial_delay_seconds = 2
            period_seconds        = 5
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "server" {
  metadata {
    name      = "sentinel-server"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = "sentinel-server"
    }

    port {
      name        = "grpc"
      port        = var.port
      target_port = var.port
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}
