"""Load database credentials from AWS Secrets Manager at runtime."""

import json
import os

import boto3


def load_db_config(secret_arn: str | None = None) -> dict:
    """
    Fetch RDS connection settings from Secrets Manager.

    Secret JSON shape (created by Terraform in this project):
    {
      "username": "etl_user",
      "password": "<generated>",
      "engine": "postgres",
      "host": "mydb.xxxxx.region.rds.amazonaws.com",
      "port": 5432,
      "dbname": "orders"
    }
    """
    resolved_arn = secret_arn or os.environ.get("DB_SECRET_ARN")
    if not resolved_arn:
        raise ValueError("DB_SECRET_ARN environment variable is required")

    client = boto3.client("secretsmanager")
    response = client.get_secret_value(SecretId=resolved_arn)
    return json.loads(response["SecretString"])
