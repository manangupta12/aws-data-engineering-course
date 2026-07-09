#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SAMPLE_FILE="$ROOT_DIR/data/sample.txt"
HDFS_PATH="/user/root/input/sample.txt"
OUTPUT_PATH="/user/root/output/wordcount"

if [[ ! -f "$SAMPLE_FILE" ]]; then
  echo "Missing sample file: $SAMPLE_FILE"
  exit 1
fi

echo "Waiting for cluster health..."
for _ in $(seq 1 60); do
  if docker inspect --format='{{.State.Health.Status}}' namenode 2>/dev/null | grep -q healthy; then
    break
  fi
  sleep 5
done

echo "Creating HDFS directory..."
docker exec namenode hdfs dfs -mkdir -p /user/root/input

echo "Uploading sample file to HDFS..."
docker exec -i namenode hdfs dfs -put -f - "$HDFS_PATH" < "$SAMPLE_FILE"

echo "Listing HDFS path..."
docker exec namenode hdfs dfs -ls /user/root/input

echo "Reading file from HDFS..."
docker exec namenode hdfs dfs -cat "$HDFS_PATH"

echo
echo "Running wordcount MapReduce job..."
docker exec namenode bash -lc \
  "hadoop jar \$(ls \$HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar | head -1) wordcount $HDFS_PATH $OUTPUT_PATH"

echo "Wordcount output:"
docker exec namenode hdfs dfs -cat "$OUTPUT_PATH/part-r-00000"

echo
echo "Smoke test passed."
