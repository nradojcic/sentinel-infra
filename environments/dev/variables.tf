variable "namespace" {
  description = "Kubernetes namespace for the Sentinel platform"
  type        = string
  default     = "sentinel-system"
}

variable "server_image" {
  description = "Container image for the Sentinel gRPC server"
  type        = string
}

variable "agent_image" {
  description = "Container image for the Sentinel agent"
  type        = string
}

variable "server_port" {
  description = "gRPC port the Sentinel server listens on"
  type        = number
  default     = 50051
}

variable "http_port" {
  description = "HTTP port for the Server dashboard"
  type        = number
  default     = 8080
}

variable "agent_replicas" {
  description = "Number of Sentinel agent replicas"
  type        = number
  default     = 3

  validation {
    condition     = var.agent_replicas >= 1 && var.agent_replicas <= 10
    error_message = "agent_replicas must be between 1 and 10."
  }
}

variable "kube_context" {
  description = "kubectl context to deploy into"
  type        = string
  default     = "minikube"
}
