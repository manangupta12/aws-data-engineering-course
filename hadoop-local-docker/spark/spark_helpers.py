"""PySpark helpers for the Hadoop-to-Spark pivot lab."""

from __future__ import annotations

from pathlib import Path

from pyspark.sql import SparkSession


MODULE_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = MODULE_DIR.parent
DATA_DIR = PROJECT_ROOT / "data" / "ecommerce"


def data_path(filename: str) -> str:
    """Return absolute path to a ShopStream sample file."""
    path = DATA_DIR / filename
    if not path.exists():
        raise FileNotFoundError("Missing sample data: {0}".format(path))
    return str(path)


def create_spark(app_name: str = "ShopStream-Spark") -> SparkSession:
    """Create a local-mode SparkSession for student labs."""
    return (
        SparkSession.builder.appName(app_name)
        .master("local[*]")
        .config("spark.sql.shuffle.partitions", "4")
        .config("spark.driver.bindAddress", "127.0.0.1")
        .config("spark.ui.enabled", "true")
        .getOrCreate()
    )


def stop_spark(spark: SparkSession) -> None:
    """Stop an active SparkSession."""
    if spark is not None:
        spark.stop()
