output "namespace" {
  description = "Namespace where Sentinel is deployed"
  value       = kubernetes_namespace.sentinel.metadata[0].name
}

output "server_service" {
  description = "Cluster-internal DNS name of the Sentinel server"
  value       = module.sentinel_server.service_name
}

output "agent_replicas" {
  description = "Number of agent replicas deployed"
  value       = module.sentinel_agent.replica_count
}
