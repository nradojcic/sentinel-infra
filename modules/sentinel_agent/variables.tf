variable "namespace" {
  description = "Kubernetes namespace to deploy into"
  type        = string
}

variable "image" {
  description = "Container image for the Sentinel agent"
  type        = string
}

variable "replicas" {
  description = "Number of agent replicas"
  type        = number
  default     = 3
}

variable "server_target" {
  description = "host:port of the Sentinel server for agents to dial"
  type        = string
}

variable "poll_interval_seconds" {
  description = "How often the agent reports metrics"
  type        = number
  default     = 5
}

variable "server_port" {
  description = "gRPC port of the Sentinel server"
  type        = number
  default     = 50051
}
