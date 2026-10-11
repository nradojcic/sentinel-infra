output "service_name" {
  description = "Name of the Kubernetes Service exposing the server"
  value       = kubernetes_service.server.metadata[0].name
}

output "deployment_name" {
  description = "Name of the server Deployment"
  value       = kubernetes_deployment.server.metadata[0].name
}
