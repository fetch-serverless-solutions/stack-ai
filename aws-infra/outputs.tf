output "vpc_id" {
  description = "VPC id"
  value       = module.vpc.vpc_id
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "rds_endpoint" {
  description = "RDS endpoint address (internal)"
  value       = module.rds.address
}

output "s3_bucket" {
  description = "Supabase S3 bucket name"
  value       = module.s3.bucket
}

output "secrets_arn" {
  description = "Secrets Manager secret ARNs"
  value       = module.secrets.secret_arn
}
