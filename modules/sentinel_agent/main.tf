resource "kubernetes_config_map_v1" "agent_config" {
  metadata {
    name      = "sentinel-agent-config"
    namespace = var.namespace
  }

  data = {
    SENTINEL_SERVER_TARGET = var.server_target
    SENTINEL_POLL_INTERVAL = tostring(var.poll_interval_seconds)
    SENTINEL_LOG_LEVEL     = "info"
  }
}

resource "kubernetes_secret_v1" "agent_secret" {
  metadata {
    name      = "sentinel-agent-secret"
    namespace = var.namespace
  }

  type = "Opaque"

  data = {
    # Placeholder — replace with real token provisioning via external secrets
    SENTINEL_AUTH_TOKEN = "REPLACE_ME"
  }

  lifecycle {
    ignore_changes = [data]
  }
}

resource "kubernetes_deployment_v1" "agent" {
  metadata {
    name      = "sentinel-agent"
    namespace = var.namespace
    labels = {
      app = "sentinel-agent"
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = "sentinel-agent"
      }
    }

    template {
      metadata {
        labels = {
          app = "sentinel-agent"
        }
      }

      spec {
        init_container {
          name  = "wait-for-server"
          image = "busybox:1.36"
          command = [
            "sh", "-c",
            "until nc -z sentinel-server ${var.server_port}; do echo waiting for sentinel-server; sleep 2; done"
          ]
        }

        container {
          name              = "agent"
          image             = var.image
          image_pull_policy = "IfNotPresent"

          command = ["/sentinel", "agent"]
          args = [
            "--agent-id=$(POD_NAME)",
            "--server-addr=${var.server_target}",
            "--interval=${var.poll_interval_seconds}",
          ]

          env {
            name = "POD_NAME"
            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map_v1.agent_config.metadata[0].name
            }
          }

          env_from {
            secret_ref {
              name = kubernetes_secret_v1.agent_secret.metadata[0].name
            }
          }

          resources {
            requests = {
              cpu    = "50m"
              memory = "64Mi"
            }
            limits = {
              cpu    = "200m"
              memory = "128Mi"
            }
          }
        }
      }
    }
  }
}
