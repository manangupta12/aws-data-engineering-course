# Local Hadoop Cluster (Docker)

Multi-node **Hadoop 3.3.6** cluster for local development and student labs.

## Student guide

**Start here:** [HADOOP-STUDENT-GUIDE.md](./HADOOP-STUDENT-GUIDE.md)

Step-by-step setup for Mac, Windows, and Linux — prerequisites, start, verify, HDFS commands, MapReduce exercises, troubleshooting.

## Quick start

```bash
git clone https://github.com/manangupta12/aws-data-engineering-course.git
cd aws-data-engineering-course/hadoop-local-docker
chmod +x scripts/*.sh      # Mac / Linux / WSL only
./scripts/start.sh
./scripts/verify.sh
./scripts/smoke-test.sh
```

Windows (PowerShell):

```powershell
git clone https://github.com/manangupta12/aws-data-engineering-course.git
cd aws-data-engineering-course\hadoop-local-docker
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned   # first time only
.\scripts\start.ps1
.\scripts\verify.ps1
.\scripts\smoke-test.ps1
```

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
./scripts/stop.sh           # stop, keep data
docker compose down -v      # stop + wipe HDFS
```

Windows: `.\scripts\stop.ps1`
