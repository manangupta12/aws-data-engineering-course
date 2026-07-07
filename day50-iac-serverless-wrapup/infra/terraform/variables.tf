variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_prefix" {
  description = "Prefix for resource names (must be globally unique for S3)"
  type        = string
}

variable "enable_rds" {
  description = "Set true to create a small RDS Postgres instance (costs money)"
  type        = bool
  default     = false
}
