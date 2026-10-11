output "deployment_name" {
  description = "Name of the agent Deployment"
  value       = kubernetes_deployment.agent.metadata[0].name
}

output "replica_count" {
  description = "Number of agent replicas configured"
  value       = var.replicas
}
