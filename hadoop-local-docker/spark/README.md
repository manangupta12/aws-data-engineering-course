# Spark Pivot Module

Student lab that **starts with Hadoop MapReduce pain points** and solves the same ShopStream analytics with **PySpark**.

## Why this module exists

After MapReduce labs, students feel the friction: multiple jobs, HDFS temp paths, mapper/reducer scripts, YARN wait time. Spark addresses those limits while still running on HDFS/YARN in production (EMR).

## Files

| Path | Purpose |
|------|---------|
| [SPARK-STUDENT-GUIDE.md](./SPARK-STUDENT-GUIDE.md) | Step-by-step written guide |
| [Spark-Pivot-Guide.ipynb](./Spark-Pivot-Guide.ipynb) | Hands-on notebook — run in order |
| `spark_helpers.py` | Local `SparkSession` + data paths |
| `hadoop_pain_points.py` | MapReduce vs Spark comparison table |
| `requirements-spark.txt` | PySpark + Jupyter dependencies |

## Prerequisites

1. Completed [HADOOP-STUDENT-GUIDE.md](../HADOOP-STUDENT-GUIDE.md) and [MAPREDUCE-STUDENT-GUIDE.md](../MAPREDUCE-STUDENT-GUIDE.md)
2. Java installed (required by Spark — same as Hadoop)
3. Optional: Docker Hadoop cluster running to demo live MapReduce friction

## Quick start

```bash
cd hadoop-local-docker/spark
python3 -m venv .venv
source .venv/bin/activate          # Windows: .venv\Scripts\activate
pip install -r requirements-spark.txt
jupyter notebook Spark-Pivot-Guide.ipynb
```

Spark UI (while notebook runs): http://localhost:4040
