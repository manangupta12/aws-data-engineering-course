output "raw_bucket_name" {
  description = "S3 bucket for incoming CSV files"
  value       = aws_s3_bucket.raw.bucket
}

output "processed_bucket_name" {
  description = "S3 bucket for transformed JSON output"
  value       = aws_s3_bucket.processed.bucket
}

output "lambda_function_name" {
  description = "Deployed Lambda function name"
  value       = aws_lambda_function.etl_orders.function_name
}

output "db_secret_arn" {
  description = "Secrets Manager ARN for database credentials"
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "rds_endpoint" {
  description = "RDS endpoint (only when enable_rds = true)"
  value       = var.enable_rds ? aws_db_instance.orders[0].endpoint : null
}
