# Local Hadoop Cluster (Docker)

Multi-node **Hadoop 3.3.6** cluster for local development and student labs.

## Student guide

**Start here:** [HADOOP-STUDENT-GUIDE.md](./HADOOP-STUDENT-GUIDE.md)

Step-by-step setup for Mac, Windows, and Linux — prerequisites, start, verify, HDFS commands, MapReduce exercises, troubleshooting.

## Class notebook (instructors)

**1-hour teaching notebook:** [Hadoop-Local-Cluster-Class.ipynb](./Hadoop-Local-Cluster-Class.ipynb)

E-commerce scenario (**ShopStream**), demos for all 7 containers, MapReduce on product reviews, AWS mapping. Sample data in `data/ecommerce/`.

## Quick start

```bash
git clone https://github.com/manangupta12/aws-data-engineering-course.git
cd aws-data-engineering-course/hadoop-local-docker

docker pull neshkeev/hadoop:3.3.6-jdk-11
docker compose up -d
docker compose ps
```

Full commands with explanations: [HADOOP-STUDENT-GUIDE.md](./HADOOP-STUDENT-GUIDE.md)

## Web UIs

| Service | URL |
|---------|-----|
| HDFS NameNode | http://localhost:9870 |
| YARN ResourceManager | http://localhost:8088 |
| MapReduce History | http://localhost:19888 |

HDFS RPC on host port **9900** (internal `namenode:9000`).

## Cluster services

| Container | Role |
|-----------|------|
| `namenode` | HDFS NameNode |
| `worker-1`, `worker-2`, `worker-3` | HDFS DataNode + YARN NodeManager |
| `resourcemanager` | YARN scheduler |
| `historyserver` | Job history |
| `proxyserver` | YARN app proxy |

Image: [neshkeev/hadoop:3.3.6-jdk-11](https://hub.docker.com/r/neshkeev/hadoop) (amd64 + arm64).

## Stop / reset

```bash
docker compose down           # stop
docker compose down -v        # stop + wipe HDFS
```

## Run the class notebook

```bash
cd hadoop-local-docker
python3 -m venv .venv
source .venv/bin/activate          # Windows: .venv\Scripts\activate
pip install -r requirements-notebook.txt
jupyter notebook Hadoop-Local-Cluster-Class.ipynb
```

Ensure the Hadoop cluster is running first (`docker compose up -d` — see [HADOOP-STUDENT-GUIDE.md](./HADOOP-STUDENT-GUIDE.md)).
