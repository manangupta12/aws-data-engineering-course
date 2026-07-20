"""Helpers for submitting and monitoring MapReduce jobs from the notebook."""

from __future__ import print_function

import re
import subprocess


STREAMING_JAR_CMD = (
    "ls $HADOOP_HOME/share/hadoop/tools/lib/hadoop-streaming-*.jar | head -1"
)
CONTAINER_STREAMING_DIR = "/tmp/mapreduce-streaming"


def run(cmd, check=False):
    """Run a shell command and return CompletedProcess."""
    return subprocess.run(
        cmd,
        shell=True,
        capture_output=True,
        text=True,
        check=check,
    )


def deploy_scripts(local_dir, script_names):
    """Copy mapper/reducer scripts into the namenode container."""
    run("docker exec namenode mkdir -p {0}".format(CONTAINER_STREAMING_DIR))
    for name in script_names:
        local_path = "{0}/{1}".format(local_dir.rstrip("/"), name)
        remote_path = "{0}/{1}".format(CONTAINER_STREAMING_DIR, name)
        result = run(
            "docker cp {0} namenode:{1}".format(local_path, remote_path)
        )
        if result.returncode != 0:
            raise RuntimeError(
                "Failed to copy {0}: {1}".format(name, result.stderr.strip())
            )
    print("Deployed: {0}".format(", ".join(script_names)))


def clear_hdfs_output(output_path):
    """Remove prior MapReduce output directory if it exists."""
    run(
        "docker exec namenode hdfs dfs -rm -r -f {0} >/dev/null 2>&1 || true".format(
            output_path
        )
    )


def submit_streaming_job(mapper, reducer, input_path, output_path):
    """Submit a Hadoop Streaming job and return combined stdout/stderr."""
    clear_hdfs_output(output_path)
    mapper_path = "{0}/{1}".format(CONTAINER_STREAMING_DIR, mapper)
    reducer_path = "{0}/{1}".format(CONTAINER_STREAMING_DIR, reducer)
    cmd = (
        "docker exec namenode bash -lc "
        "'hadoop jar $("
        + STREAMING_JAR_CMD
        + ") "
        "-files {0},{1} "
        '-mapper "python {2}" '
        '-reducer "python {3}" '
        "-input {4} "
        "-output {5}'"
    ).format(
        mapper_path,
        reducer_path,
        mapper,
        reducer,
        input_path,
        output_path,
    )
    result = run(cmd)
    output = (result.stdout or "") + (result.stderr or "")
    print(output)
    if result.returncode != 0:
        raise RuntimeError("Streaming job failed")
    return output


def extract_tracking_url(job_log):
    """Pull YARN tracking URL from Hadoop job log text."""
    match = re.search(r"http://proxyserver:\d+/proxy/application_[^/\s]+/", job_log)
    return match.group(0) if match else None


def list_yarn_applications(state="ALL", limit=10):
    """List recent YARN applications."""
    result = run(
        "docker exec resourcemanager yarn application -list -appStates {0}".format(
            state
        )
    )
    print(result.stdout or result.stderr)
    return result.stdout


def get_latest_application_id(state="FINISHED"):
    """Return the most recent YARN application id for a given state."""
    result = run(
        "docker exec resourcemanager yarn application -list -appStates {0}".format(
            state
        )
    )
    text = result.stdout or ""
    matches = re.findall(r"(application_\d+_\d+)", text)
    return matches[0] if matches else None


def application_status(app_id):
    """Print status for one YARN application id."""
    result = run(
        "docker exec resourcemanager yarn application -status {0}".format(app_id)
    )
    print(result.stdout or result.stderr)
    return result.stdout


def read_hdfs_output(output_path, top_n=15):
    """Read part files from HDFS output and print top lines by count."""
    cmd = (
        "docker exec namenode bash -lc "
        "'hdfs dfs -cat {0}/part-* | sort -t$'\\''\\t'\\'' -k2 -nr | head -{1}'"
    ).format(output_path, top_n)
    result = run(cmd)
    print(result.stdout or result.stderr)
    return result.stdout
