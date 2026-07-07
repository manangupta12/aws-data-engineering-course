import csv
import io
import json
import os
from datetime import datetime, timezone

import boto3

from transform import row_to_record

RAW_BUCKET = os.environ.get("RAW_BUCKET", "day50-orders-raw")
PROCESSED_BUCKET = os.environ.get("PROCESSED_BUCKET", "day50-orders-processed")
DEFAULT_KEY = os.environ.get("S3_KEY", "incoming/orders.csv")


def lambda_handler(event, context):
    s3 = boto3.client("s3")

    bucket = event.get("bucket", RAW_BUCKET)
    key = event.get("key", DEFAULT_KEY)

    response = s3.get_object(Bucket=bucket, Key=key)
    body = response["Body"].read().decode("utf-8")

    reader = csv.DictReader(io.StringIO(body))
    records = [row_to_record(row, key) for row in reader]

    output_key = (
        f"processed/{datetime.now(timezone.utc).strftime('%Y/%m/%d')}/"
        f"{key.replace('/', '_').replace('.csv', '')}.json"
    )

    s3.put_object(
        Bucket=PROCESSED_BUCKET,
        Key=output_key,
        Body=json.dumps(records, indent=2).encode("utf-8"),
        ContentType="application/json",
    )

    return {
        "statusCode": 200,
        "body": json.dumps(
            {
                "message": "ETL completed successfully",
                "source_bucket": bucket,
                "source_key": key,
                "destination_bucket": PROCESSED_BUCKET,
                "destination_key": output_key,
                "records_processed": len(records),
            }
        ),
    }
