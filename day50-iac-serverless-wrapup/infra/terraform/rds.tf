# Optional RDS — enable with enable_rds = true (incurs AWS charges)

resource "aws_db_subnet_group" "orders" {
  count      = var.enable_rds ? 1 : 0
  name       = "${var.project_prefix}-orders-db-subnet"
  subnet_ids = data.aws_subnets.default[0].ids
}

data "aws_vpc" "default" {
  count   = var.enable_rds ? 1 : 0
  default = true
}

data "aws_subnets" "default" {
  count = var.enable_rds ? 1 : 0

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default[0].id]
  }
}

resource "aws_security_group" "rds" {
  count       = var.enable_rds ? 1 : 0
  name        = "${var.project_prefix}-rds-sg"
  description = "Allow Postgres access for Day 50 demo"
  vpc_id      = data.aws_vpc.default[0].id

  ingress {
    description = "Postgres from VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.default[0].cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "orders" {
  count                  = var.enable_rds ? 1 : 0
  identifier             = "${var.project_prefix}-orders-db"
  engine                 = "postgres"
  engine_version         = "16"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = "orders"
  username               = "etl_user"
  password               = random_password.db_password.result
  db_subnet_group_name   = aws_db_subnet_group.orders[0].name
  vpc_security_group_ids = [aws_security_group.rds[0].id]
  skip_final_snapshot    = true
  publicly_accessible    = false
}
