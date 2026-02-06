resource "aws_security_group" "rds" {
  name        = "rds-sg-${var.environment}"
  description = "RDS SG - allows Postgres only from provided security groups"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.sg_allow_from
    content {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      security_groups = [ingress.value]
      description = "Allow Postgres from EKS"
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = var.environment
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnets-${var.environment}"
  subnet_ids = var.subnets
  tags = {
    Environment = var.environment
  }
}

resource "aws_db_instance" "postgres" {
  identifier = "postgres-${var.environment}"
  engine     = "postgres"
  instance_class = "db.t3.medium"

  username = var.username
  password = var.password

  allocated_storage    = 20
  max_allocated_storage = 100

  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  multi_az = true
  publicly_accessible = false

  skip_final_snapshot = true

  backup_retention_period = 7

  tags = {
    Environment = var.environment
  }
}

 
