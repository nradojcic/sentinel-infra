variable "namespace" {
  description = "Kubernetes namespace to deploy into"
  type        = string
}

variable "image" {
  description = "Container image for the Sentinel server"
  type        = string
}

variable "port" {
  description = "gRPC port to expose"
  type        = number
  default     = 50051
}

variable "http_port" {
  description = "HTTP port to expose for the dashboard"
  type        = number
  default     = 8080
}

variable "replicas" {
  description = "Number of server replicas"
  type        = number
  default     = 1
}
