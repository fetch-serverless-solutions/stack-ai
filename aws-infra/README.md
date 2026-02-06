# AWS Infra Terraform

This folder contains modular Terraform configuration to provision:
- VPC with public/private subnets + NAT
- EKS cluster deployed into private subnets
- Multi-AZ RDS PostgreSQL in private subnets
- Encrypted S3 bucket for Supabase object storage
- Secrets Manager entries for sensitive configs

Usage:

1. Set AWS credentials in environment.
2. Update `variables.tf` defaults or pass via `-var`/tfvars.
3. Run:

```bash
terraform init
terraform plan -out plan.tfplan
terraform apply plan.tfplan
```

Notes:
- The configs call community modules for VPC and EKS. Review IAM policies before applying.
- Replace placeholder DB password handling with secure secrets pipeline for production.
