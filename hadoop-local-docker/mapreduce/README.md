# MapReduce Module

Python MapReduce labs for the local Docker Hadoop cluster.

## Files

| Path | Purpose |
|------|---------|
| `local_simulation.py` | Pure-Python map/shuffle/reduce — test logic without Hadoop |
| `job_helpers.py` | Deploy scripts, submit Streaming jobs, read HDFS output, list YARN apps |
| `streaming/wordcount_mapper.py` | Map: emit `(word, 1)` for each token |
| `streaming/wordcount_reducer.py` | Reduce: sum counts per word |
| `streaming/sentiment_mapper.py` | Map: tag reviews with positive/negative keywords |
| `streaming/sentiment_reducer.py` | Reduce: sum sentiment category counts |

## Student materials

- **Guide:** [../MAPREDUCE-STUDENT-GUIDE.md](../MAPREDUCE-STUDENT-GUIDE.md)
- **Notebook:** [../Hadoop-MapReduce-Guide.ipynb](../Hadoop-MapReduce-Guide.ipynb)

## Quick start

```bash
# From hadoop-local-docker/ with cluster running
python3 -c "
from mapreduce.job_helpers import deploy_scripts, submit_streaming_job, read_hdfs_output
deploy_scripts('mapreduce/streaming', ['wordcount_mapper.py', 'wordcount_reducer.py'])
submit_streaming_job('wordcount_mapper.py', 'wordcount_reducer.py',
    '/shopstream/raw/reviews/product_reviews.txt',
    '/shopstream/processed/python_wordcount')
read_hdfs_output('/shopstream/processed/python_wordcount')
"
```

## Local pipeline test (no Hadoop)

```bash
cat data/ecommerce/product_reviews.txt \
  | python3 mapreduce/streaming/wordcount_mapper.py \
  | sort \
  | python3 mapreduce/streaming/wordcount_reducer.py
```
