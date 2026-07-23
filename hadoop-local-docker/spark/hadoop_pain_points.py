"""Summarize MapReduce friction vs Spark for the pivot class."""

from __future__ import annotations

from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parent.parent
STREAMING_DIR = PROJECT_ROOT / "mapreduce" / "streaming"


PAIN_POINTS = [
    {
        "issue": "Multi-step analytics needs many jobs",
        "hadoop": "Each step = new MapReduce job + HDFS temp folder + cleanup",
        "spark": "One Spark app chains transforms in memory or with lazy DAG",
    },
    {
        "issue": "Shuffle writes to disk",
        "hadoop": "Map output spills to disk, shuffle over network, reduce reads disk",
        "spark": "Shuffle still exists but optimized; intermediate data can stay in memory",
    },
    {
        "issue": "Heavy boilerplate",
        "hadoop": "Separate mapper/reducer scripts, deploy, streaming JAR submit",
        "spark": "Single PySpark notebook or script with DataFrame API",
    },
    {
        "issue": "Slow iteration",
        "hadoop": "YARN container startup + job submit per experiment",
        "spark": "REPL-style cells; rerun pipeline in seconds locally",
    },
    {
        "issue": "Limited programming model",
        "hadoop": "Map and reduce only — joins/filters need custom code or extra jobs",
        "spark": "SQL, joins, window functions, MLlib in one engine",
    },
    {
        "issue": "Python version lock-in",
        "hadoop": "Streaming uses Python 2.7 in our Docker image",
        "spark": "Modern Python 3 PySpark on laptop or EMR",
    },
]


def streaming_script_line_count() -> int:
    """Count lines in wordcount mapper + reducer scripts."""
    files = [
        STREAMING_DIR / "wordcount_mapper.py",
        STREAMING_DIR / "wordcount_reducer.py",
    ]
    return sum(len(path.read_text(encoding="utf-8").splitlines()) for path in files)


def print_pain_summary() -> None:
    """Print a student-friendly comparison table."""
    print("MapReduce pain points vs Spark\n")
    print("{:<34} {:<42} {}".format("Issue", "Hadoop MapReduce", "Apache Spark"))
    print("-" * 120)
    for row in PAIN_POINTS:
        print("{:<34} {:<42} {}".format(row["issue"], row["hadoop"], row["spark"]))
    print("\nWordcount streaming scripts: ~{0} lines (mapper + reducer)".format(
        streaming_script_line_count()
    ))
    print("Equivalent PySpark wordcount: ~5 lines in a notebook cell")
