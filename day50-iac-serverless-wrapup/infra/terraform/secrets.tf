resource "random_password" "db_password" {
  length  = 20
  special = true
}

resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "${var.project_prefix}/rds/orders-db"
  description = "RDS credentials for orders ETL (Day 50 demo)"
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id

  secret_string = jsonencode({
    username = "etl_user"
    password = random_password.db_password.result
    engine   = "postgres"
    host     = var.enable_rds ? aws_db_instance.orders[0].address : "localhost"
    port     = 5432
    dbname   = "orders"
  })
}
