#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib.sh
source "$ROOT_DIR/scripts/lib.sh"

SAMPLE_FILE="$ROOT_DIR/data/sample.txt"
HDFS_PATH="/user/root/input/sample.txt"
OUTPUT_PATH="/user/root/output/wordcount"

cd "$ROOT_DIR"
require_docker

if [[ ! -f "$SAMPLE_FILE" ]]; then
  echo "Missing sample file: $SAMPLE_FILE"
  exit 1
fi

wait_for_cluster 300

echo "Creating HDFS directory..."
docker exec namenode hdfs dfs -mkdir -p /user/root/input

echo "Uploading sample file to HDFS..."
docker cp "$SAMPLE_FILE" namenode:/tmp/sample.txt
docker exec namenode hdfs dfs -put -f /tmp/sample.txt "$HDFS_PATH"

echo "Listing HDFS path..."
docker exec namenode hdfs dfs -ls /user/root/input

echo "Reading file from HDFS..."
docker exec namenode hdfs dfs -cat "$HDFS_PATH"

echo
echo "Running wordcount MapReduce job..."
docker exec namenode hdfs dfs -rm -r -f "$OUTPUT_PATH" >/dev/null 2>&1 || true
docker exec namenode bash -lc \
  "hadoop jar \$(ls \$HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar | head -1) wordcount $HDFS_PATH $OUTPUT_PATH"

echo "Wordcount output:"
docker exec namenode hdfs dfs -cat "$OUTPUT_PATH/part-r-00000"

echo
echo "Smoke test passed."
