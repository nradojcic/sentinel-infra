output "service_name" {
  description = "Name of the Kubernetes Service exposing the server"
  value       = kubernetes_service_v1.server.metadata[0].name
}

output "deployment_name" {
  description = "Name of the server Deployment"
  value       = kubernetes_deployment_v1.server.metadata[0].name
}
