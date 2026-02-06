resource "aws_secretsmanager_secret" "supabase" {
  name = "supabase-${var.environment}"
  description = "Secrets for Supabase stack in ${var.environment}"
  tags = {
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "supabase_version" {
  secret_id     = aws_secretsmanager_secret.supabase.id
  secret_string = jsonencode(var.postgres_secret)
}

output "secret_arn" {
  value = aws_secretsmanager_secret.supabase.arn
}
