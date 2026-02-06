variable "region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment tag (dev/stage/prod)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability zones to use (at least 2)"
  type        = list(string)
  default     = []
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "test-ai-cluster"
}

variable "postgres_username" {
  description = "Postgres master username"
  type        = string
  default     = "pgadmin"
}

variable "postgres_password" {
  description = "Postgres master password (recommend set via environment or secrets)"
  type        = string
  default     = "changeme"
  sensitive   = true
}
