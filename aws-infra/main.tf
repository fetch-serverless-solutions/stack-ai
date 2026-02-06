/*
  Root composition file: wires modules together
  - module.vpc creates network with public/private subnets and NAT
  - module.eks deploys an EKS cluster into private subnets
  - module.rds creates a multi-AZ PostgreSQL instance in private subnets
  - module.s3 creates an encrypted bucket for general storage
  - module.secrets stores initial secrets in Secrets Manager
*/

module "vpc" {
  source = "./modules/vpc"

  environment     = var.environment
  vpc_cidr        = var.vpc_cidr
  public_subnets  = ["10.0.0.0/24", "10.0.1.0/24"]
  private_subnets = ["10.0.10.0/24", "10.0.11.0/24"]
}

module "eks" {
  source = "./modules/eks"

  environment              = var.environment
  cluster_name             = var.cluster_name
  vpc_id                   = module.vpc.vpc_id
  vpc_cidr                 = var.vpc_cidr
  private_subnet_ids       = module.vpc.private_subnet_ids
  control_plane_subnet_ids = module.vpc.private_subnet_ids
}

module "rds" {
  source = "./modules/rds"

  vpc_id        = module.vpc.vpc_id
  subnets       = module.vpc.private_subnet_ids
  sg_allow_from = [module.eks.node_security_group_id]

  username    = var.postgres_username
  password    = var.postgres_password
  environment = var.environment
}

module "s3" {
  source      = "./modules/s3"
  environment = var.environment
}

module "secrets" {
  source      = "./modules/secrets"
  environment = var.environment
  postgres_secret = {
    username = var.postgres_username
    password = var.postgres_password
    host     = module.rds.address
  }
}
