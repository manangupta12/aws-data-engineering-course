import json
from unittest.mock import MagicMock, patch

from etl_orders.db_config import load_db_config


@patch("etl_orders.db_config.boto3.client")
def test_load_db_config_reads_secret(mock_boto_client):
    secret_payload = {
        "username": "etl_user",
        "password": "generated-password",
        "host": "mydb.example.rds.amazonaws.com",
        "port": 5432,
        "dbname": "orders",
    }
    mock_client = MagicMock()
    mock_client.get_secret_value.return_value = {
        "SecretString": json.dumps(secret_payload),
    }
    mock_boto_client.return_value = mock_client

    config = load_db_config(secret_arn="arn:aws:secretsmanager:us-east-1:123:secret:demo")

    assert config["username"] == "etl_user"
    assert config["password"] == "generated-password"
    mock_client.get_secret_value.assert_called_once_with(
        SecretId="arn:aws:secretsmanager:us-east-1:123:secret:demo"
    )
